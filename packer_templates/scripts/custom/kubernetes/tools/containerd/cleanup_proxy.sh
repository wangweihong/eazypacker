#!/bin/bash
set -e
set -x

proxyFile="/etc/systemd/system/containerd.service.d/http-proxy.conf"
rm ${proxyFile} || true

# 保留noproxy设置
proxyFile="/etc/systemd/system/containerd.service.d/http-proxy.conf"
no_proxy="127.0.0.1,locahost,10.96.0.1"

mkdir -p $(dirname "$proxyFile")
cat <<EOF > "$proxyFile"
[Service]
Environment="NO_PROXY=${no_proxy}"
EOF