#!/bin/bash
set -e
set -x

# config docker proxy
dockerProxyFile="/etc/systemd/system/docker.service.d/http-proxy.conf"
rm ${dockerProxyFile} || true