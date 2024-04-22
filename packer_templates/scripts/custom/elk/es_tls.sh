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
        echo "Usage: common_generate_certificate ./_output/certs example-server /CN=example-server 127.0.0.1,localhost server "
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

    cat >${v3ExtFILE} <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = ${usage}
EOF

    if [ ${cert_san} != "\"\"" ]; then
        cat >>${v3ExtFILE} <<-EOF
subjectAltName = @alt_names

[alt_names]
EOF

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



ESVERSION="8.10.4"
ESNAME="es01"
ROOT_DIR=/elk/es
CA_PASSWORD=elastic
ELK_IP="172.22.0.100"

cat <<EOF >>$ROOT_DIR/config/elasticsearch.yml

xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.client_authentication: required
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
EOF

#if [ "${ES_TLS+isset}" = "isset" ] && [ "${ES_TLS}" = "true" ]; then
# https://www.elastic.co/guide/en/elasticsearch/reference/8.13/security-basic-setup.html#encrypt-internode-communication
echo "config basid security for elasticsearch..."
sudo -s docker exec $ESNAME elasticsearch-certutil ca --out /usr/share/elasticsearch/config/elastic-stack-ca.p12 --pass $CA_PASSWORD --days 3650
# generate certificates
sudo -s docker exec $ESNAME elasticsearch-certutil cert \
    --ca /usr/share/elasticsearch/config/elastic-stack-ca.p12 --ca-pass $CA_PASSWORD \
    --out /usr/share/elasticsearch/config/elastic-certificates.p12 --pass $CA_PASSWORD

# 证书密码到keystore
# 不能直接通过配置文件来设置。
echo $CA_PASSWORD | sudo -s docker exec -i $ESNAME elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password -s
echo $CA_PASSWORD | sudo -s docker exec -i $ESNAME elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password -s

chmod 666 $ROOT_DIR/config/elastic-stack-ca.p12
chmod 666 $ROOT_DIR/config/elastic-certificates.p12

# 配置http层证书
# https://www.elastic.co/guide/en/elasticsearch/reference/8.13/security-basic-setup-https.html
# 官方提供的方式无法通过非交互命令来实现证书的生成

mkdir -p $ROOT_DIR/pki
chmod 666 $ROOT_DIR/pki

pushd $ROOT_DIR/pki

openssl pkcs12 -in $ROOT_DIR/config/elastic-stack-ca.p12 -nocerts -nodes -out ca.key \
    -passin pass:$CA_PASSWORD -passout pass:$CA_PASSWORD
openssl pkcs12 -in $ROOT_DIR/config/elastic-stack-ca.p12 -out ca.crt \
    -passin pass:$CA_PASSWORD -passout pass:$CA_PASSWORD
common_generate_certificate $ROOT_DIR/pki es01 /CN=elk 127.0.0.1,localhost,es01.com,$ELK_IP server
openssl pkcs12 -export -out es01.p12 -inkey es01.key -in es01.crt -certfile ca.crt -passout pass:$CA_PASSWORD

popd

cp $ROOT_DIR/pki/es01.p12 /$ROOT_DIR/config/
chmod 666 $ROOT_DIR/config/es01.p12

cat <<EOF >>$ROOT_DIR/config/elasticsearch.yml

xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: es01.p12

EOF

echo $CA_PASSWORD | sudo -s docker exec -i $ESNAME elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password -s

docker restart $ESNAME