#!/bin/bash
set -e
set -x

# 配置apt代理
cat > /etc/apt/apt.conf << EOF
Acquire::http::Proxy "${HTTP_PROXY}";
Acquire::https::Proxy "${HTTPS_PROXY}";
EOF

sleep 3