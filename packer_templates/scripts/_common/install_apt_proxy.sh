#!/bin/bash
set -e
set -x

# 配置apt代理
cat > /etc/apt/apt.conf << EOF
Acquire::http::Proxy "${http_proxy}";
Acquire::https::Proxy "${https_proxy}";
EOF

sleep 3