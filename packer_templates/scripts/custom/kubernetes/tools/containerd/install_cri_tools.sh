#!/bin/bash
set -e
set -x

# see https://github.com/kubernetes-sigs/cri-tools/tree/master
# It's recommended to use the same cri-tools and Kubernetes minor version, 
# because new features added to the Container Runtime Interface (CRI) may not be fully supported if they diverge.

curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/crictl.tar.gz
sudo tar zxvf /tmp/crictl.tar.gz -C /usr/local/bin

cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true
pull-image-on-create: false
EOF