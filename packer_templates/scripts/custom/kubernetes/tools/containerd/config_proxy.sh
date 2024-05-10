#!/usr/bin/env bash

set -e
set -x

# config proxy
proxyFile="/etc/systemd/system/containerd.service.d/http-proxy.conf"

# 创建目录 /etc/systemd/system/containerd.service.d/ 如果不存在
mkdir -p $(dirname "$proxyFile")

if [ ! -e "$proxyFile" ]; then
    echo "Creating $proxyFile and setting containerd proxy..."
    cat <<EOF > "$proxyFile"
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
EOF
else
    # 读取现有的代理设置
    currentHttpProxy=$(grep -oP 'Environment="HTTP_PROXY=\K[^"]*' "$proxyFile")
    currentHttpsProxy=$(grep -oP 'Environment="HTTPS_PROXY=\K[^"]*' "$proxyFile")

    # 检查是否需要更新代理设置
    if [ "$currentHttpProxy" != "${http_proxy}" ] || [ "$currentHttpsProxy" != "${https_proxy}" ]; then
        echo "Updating $proxyFile..."
        # 使用不同的分隔符来替换现有的代理设置
        sed -i "s|Environment=\"HTTP_PROXY=.*|Environment=\"HTTP_PROXY=${http_proxy}\"|" "$proxyFile"
        sed -i "s|Environment=\"HTTPS_PROXY=.*|Environment=\"HTTPS_PROXY=${https_proxy}\"|" "$proxyFile"
    else
        echo "$proxyFile already exists and is up to date."
    fi
fi


systemctl daemon-reload && systemctl restart containerd