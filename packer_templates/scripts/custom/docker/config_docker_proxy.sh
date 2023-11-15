#!/usr/bin/env bash
# script for config apt/wget/curl/docker proxy
set -e

# config docker proxy
dockerProxyFile="/etc/systemd/system/docker.service.d/http-proxy.conf"

# 创建目录 /etc/systemd/system/docker.service.d/ 如果不存在
mkdir -p $(dirname "$dockerProxyFile")

# 检查是否存在代理配置文件 /etc/systemd/system/docker.service.d/http-proxy.conf
if [ ! -e "$dockerProxyFile" ]; then
    echo "Creating $dockerProxyFile and setting Docker proxy..."
    cat <<EOF > "$dockerProxyFile"
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
EOF
else
    # 读取现有的代理设置
    currentHttpProxy=$(grep -oP 'Environment="HTTP_PROXY=\K[^"]*' "$dockerProxyFile")
    currentHttpsProxy=$(grep -oP 'Environment="HTTPS_PROXY=\K[^"]*' "$dockerProxyFile")

    # 检查是否需要更新代理设置
    if [ "$currentHttpProxy" != "${http_proxy}" ] || [ "$currentHttpsProxy" != "${https_proxy}" ]; then
        echo "Updating $dockerProxyFile..."
        # 使用不同的分隔符来替换现有的代理设置
        sed -i "s|Environment=\"HTTP_PROXY=.*|Environment=\"HTTP_PROXY=${http_proxy}\"|" "$dockerProxyFile"
        sed -i "s|Environment=\"HTTPS_PROXY=.*|Environment=\"HTTPS_PROXY=${https_proxy}\"|" "$dockerProxyFile"
    else
        echo "$dockerProxyFile already exists and is up to date."
    fi
fi

# 重新加载 Docker 服务配置
systemctl daemon-reload
# 重新启动 Docker 服务
systemctl restart docker