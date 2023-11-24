#!/usr/bin/env bash
set -e
set -x

arch=${OS_ARCH}
if [ ${OS_ARCH} = "x86_64" ];then 
    arch="amd64"
fi

wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-${arch}.tar.gz -O /tmp/helm-v${HELM_VERSION}-linux-${arch}.tar.gz
tar xvzf /tmp/helm-v${HELM_VERSION}-linux-${arch}.tar.gz -C /tmp
cp /tmp/linux-${arch}/helm /bin/