#!/bin/bash
set -e
set -x

proxyFile="/etc/systemd/system/containerd.service.d/http-proxy.conf"
rm ${proxyFile} || true