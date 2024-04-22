#!/bin/bash
set -ex


# 搭建一个goproxy router, 将 goproxy的请求路由到https://goproxy.cn代理。
# -proxy https://groxy.cn指启动路由模式，将请求路由到groxy.cn
docker run -d --restart=always -p 8888:8081  goproxy/goproxy -proxy https://goproxy.cn

# 使用方式
# export GO111MODULE=on
# export GOPROXY="http://<ip:port>:8888,direct"