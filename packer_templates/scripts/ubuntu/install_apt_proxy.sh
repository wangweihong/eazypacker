#!/bin/bash
set -e
set -x

if [ -e /etc/apt/apt.conf ]; then
    mv /etc/apt/apt.conf  /etc/apt/apt.conf.bk
fi

# 配置apt代理
cat > /etc/apt/apt.conf << EOF
Acquire::http::Proxy "${http_proxy}";
Acquire::https::Proxy "${https_proxy}";
EOF

sleep 3