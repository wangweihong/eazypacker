#!/bin/bash
set -ex

# https://signoz.io/docs/install/docker/
SIGNOZ_VERSION=${SIGNOZ_VERSION:-v0.48.1}

# 注意在docker-compose 版本v2.28.1测试成功运行
git clone -b ${SIGNOZ_VERSION} https://github.com/SigNoz/signoz.git && cd signoz/deploy/
./install.sh 
# docker-compose -f signoz/deploy/docker/clickhouse-setup/docker-compose.yaml up -d

# visist <ip:port>:3301

# TODO: create default username and password
# import prefined dashboards