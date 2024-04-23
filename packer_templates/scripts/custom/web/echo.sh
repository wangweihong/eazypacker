#!/bin/bash

# https://github.com/mendhak/docker-http-https-echo?tab=readme-ov-file
# 用于web调试
docker run -d --name echo -p 8888:8080 -p 8443:8443 --rm -t mendhak/http-https-echo:33