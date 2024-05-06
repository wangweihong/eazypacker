#!/usr/bin/env bash
set -ex

KUBE_RELEASE=1.18.0
KUBE_ARCH=amd64

echo "install kubernetes bash completion"
if [ "${KUBE_RELEASE+isset}" = "isset" ]; then
    KUBE_VERISON=${KUBE_RELEASE}
fi
apt install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

echo "install kubernetes kubectl-convert"
curl -LO "https://dl.k8s.io/release/v${KUBE_RELEASE}/bin/linux/${KUBE_ARCH}/kubectl-convert"

