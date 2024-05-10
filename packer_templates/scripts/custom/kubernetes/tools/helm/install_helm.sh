#!/usr/bin/env bash
set -e
set -x

curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/helm-v${HELM_VERSION}-linux-${KUBE_ARCH}.tar.gz
tar xvzf /tmp/helm-v${HELM_VERSION}-linux-${KUBE_ARCH}.tar.gz -C /tmp
cp /tmp/linux-${KUBE_ARCH}/helm /bin/