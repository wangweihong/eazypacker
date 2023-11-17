#!/bin/bash
set -e
set -x
# 安装yq工具
# 类似于jq工具，直接提取yaml等类型文件

VERSION=v4.2.0
BINARY=yq_linux_amd64

if [  -n "${OS_ARCH}" ] && [ "${OS_ARCH}" = "aarch" ]; then
    BINARY=yq_linux_${OS_ARCH}
fi

wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq