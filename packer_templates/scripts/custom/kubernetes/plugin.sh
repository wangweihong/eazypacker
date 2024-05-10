#!/usr/bin/env bash
set -ex

apt install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

echo "install kubernetes kubectl-convert"
curl -LO "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl-convert"

