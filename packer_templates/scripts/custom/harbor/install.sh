#!/usr/bin/env bash
set -e
set -x

TOOL_DIR=/etc/cloudtool
mkdir -p ${TOOL_DIR}
mkdir -p ${TOOL_DIR}/harbor/certs
mkdir -p ${TOOL_DIR}/harbor/data

# 1. download offine harbor installer
wget https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz -O ${TOOL_DIR}/harbor-offline-installer-v${HARBOR_VERSION}.tgz

tar xvzf ${TOOL_DIR}/harbor-offline-installer-v${HARBOR_VERSION}.tgz -C ${TOOL_DIR}/

cat >${TOOL_DIR}/generate_cert.sh << 'EOF'
#!/bin/bash
set -e
set -x 

# Args:
#   $1 (the directory that certificate files to save)
#   $2 (the prefix of the certificate filename)
#   $3 (cert subject alternative name)
#   $4 (cert subject common name )
#   $5 (server mode: server or client)
function common_generate_certificate() {
    local cert_dir=${1}
    local prefix=${2}
    local cert_cn=${3}  # 证书主题通用名称(Common Name)
    local cert_san=${4} # 证书主题备用名称(Subject Alternative Name)
    local mode=${5}
    local OPENSSL_BIN=$(which openssl)

    if [ $# -ne 5 ]; then
        echo "Usage: common_generate_certificate ./_output/certs example-server  /CN=example-server 127.0.0.1,localhost server "
        exit 1
    fi

    # 证书主题通用名或者证书主题备用名至少设置一个
    if [ -z ${cert_san} -a -z ${cert_cn} ]; then
        echo "cert common name \"${cert_cn}\"or subject alternative name \"${cert_san}\" at least set one"
        exit 1
    fi

    usage="serverAuth"
    if [ ${mode} = "client" ]; then
        usage="clientAuth"
    fi

    mkdir -p "${cert_dir}"

    # 确认openssl是否安装
    
    # 将当前路径入栈,并跳转到证书目录
    pushd "${cert_dir}"

    # 如果ca证书不存在, 则生成自签名ca证书
    if [ ! -r "ca.crt" ]; then
        echo "ca.crt not exist, trying to generate ca.art in ${cert_dir} "
        ${OPENSSL_BIN} genrsa -out ca.key 4096
        ${OPENSSL_BIN} req -x509 -new -nodes -sha512 -days 3650 \
            -subj "$cert_cn" \
            -key ca.key \
            -out ca.crt
    fi

    echo "Generate "${prefix}" certificates in ${cert_dir}"

    # 生成私钥
    ${OPENSSL_BIN} genrsa -out ${prefix}.key 4096
    # 生成证书签名请求
    ${OPENSSL_BIN} req -sha512 -new \
        -subj "$cert_cn" \
        -key ${prefix}.key \
        -out ${prefix}.csr

    v3ExtFILE=${prefix}_v3.ext

    cat >${v3ExtFILE} <<-INNER_EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = ${usage}
INNER_EOF

    if [ ${cert_san} != "\"\"" ]; then
        cat >>${v3ExtFILE} <<-INNER_EOF
subjectAltName = @alt_names

[alt_names]
INNER_EOF

        # 按,切割证书可选主题
        IFS=',' read -ra elements <<<"${cert_san}"

        # 使用循环遍历主题，生成证书主题
        j=0
        for ((i = 0; i < ${#elements[@]}; i++)); do
            element="${elements[$i]}"
            if [[ $element =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                # 如果是IP地址，则给 IP.* 赋值
                echo "IP.$((j = j + 1)) = $element" >>${v3ExtFILE}
            fi
        done

        j=0
        for ((i = 0; i < ${#elements[@]}; i++)); do
            element="${elements[$i]}"
            if [[ ! $element =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                # 否则，给 DNS.* 赋值
                echo "DNS.$((j = j + 1)) = $element" >>${v3ExtFILE}
            fi
        done
    fi

    ${OPENSSL_BIN} x509 -req -sha512 -days 3650 \
        -extfile ${v3ExtFILE} \
        -CA ca.crt -CAkey ca.key -CAcreateserial \
        -in ${prefix}.csr \
        -out ${prefix}.crt

    # 跳回到上一次入栈的路径
    popd
}
EOF
chmod +x ${TOOL_DIR}/generate_cert.sh

certCN=127.0.0.1,\${localIP},localhost 
domain=\${localIP}

# "${HARBOR_DOMAIN+isset}" = "isset" 是为了避免HARBOR_DOMAIN没有设置时直接出错，而非判定为false
if [ "${HARBOR_DOMAIN+isset}" = "isset" ]; then
    domain=${HARBOR_DOMAIN}
    certCN=127.0.0.1,\${localIP},${HARBOR_DOMAIN},localhost 
fi

# 'EOF'关闭转义
cat >${TOOL_DIR}/install_harbor.sh <<EOF
#!/bin/bash
set -e
set -x 

# newer system doesn't has ifconfig
if command -v ifconfig &> /dev/null; then
    # 使用 ifconfig 命令
    localIP=$(ifconfig eth0 | awk '/inet /{print $2}' | cut -d':' -f2)
else
    # 使用 ip 命令
    localIP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
fi

certCN=${certCN}
domain=${domain}

sed -i -e "s#/your/certificate/path#${TOOL_DIR}/harbor/certs/${domain}.crt#g" ${TOOL_DIR}/harbor/harbor.yml.tmpl
    sed -i -e "s#/your/private/key/path#${TOOL_DIR}/harbor/certs/${domain}.key#g" ${TOOL_DIR}/harbor/harbor.yml.tmpl
    sed -i -e "s#reg.mydomain.com#\${domain}#g" ${TOOL_DIR}/harbor/harbor.yml.tmpl
    sed -i -e "s#data_volume: /data#data_volume: ${TOOL_DIR}/harbor/data#g" ${TOOL_DIR}/harbor/harbor.yml.tmpl
    # harbor only work with harbor.yml
    mv ${TOOL_DIR}/harbor/harbor.yml.tmpl ${TOOL_DIR}/harbor/harbor.yml

source /etc/cloudtool/generate_cert.sh
# generate certs
common_generate_certificate /etc/cloudtool/harbor/certs ${domain}  /CN=harbor_server ${certCN} server

# copy to docker
mkdir -p /etc/docker/certs.d/${domain}
cp /etc/cloudtool/harbor/certs/${domain}.crt /etc/docker/certs.d/${domain}/${domain}.cert
cp /etc/cloudtool/harbor/certs/${domain}.key /etc/docker/certs.d/${domain}/
cp /etc/cloudtool/harbor/certs/ca.crt /etc/docker/certs.d/${domain}/

# ${TOOL_DIR}/harbor/install.sh --with-trivy --with-chartmuseum --with-clair
# newer version has remove chartmeseum and notary
${TOOL_DIR}/harbor/install.sh --with-trivy 

# disable auto install service
systemctl disable install_harbor_once || true
EOF
chmod +x ${TOOL_DIR}/install_harbor.sh

# /etc/systemd/system/install_harbor_once.service
cat >/etc/systemd/system/install_harbor_once.service <<EOF
[Unit]
Description=Run Install Harbor Once Script
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=${TOOL_DIR}/install_harbor.sh

[Install]
WantedBy=default.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable install_harbor_once.service
