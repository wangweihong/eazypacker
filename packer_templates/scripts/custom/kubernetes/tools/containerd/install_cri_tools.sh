#!/bin/bash
set -e
set -x

KUBE_VERSION=${KUBE_VERSION:-1.30.0}
KUBE_ARCH=${KUBE_ARCH:-amd64}
NETCTL_VERSION=${NETCTL_VERSION:-2.0.0-beta.5}
# crictl版本和kubernetes版本保持一致
CRICTL_VERSION=${KUBE_VERSION:-1.30.0}



# see https://github.com/kubernetes-sigs/cri-tools/tree/master
# It's recommended to use the same cri-tools and Kubernetes minor version, 
# because new features added to the Container Runtime Interface (CRI) may not be fully supported if they diverge.

curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/crictl.tar.gz
sudo tar zxvf /tmp/crictl.tar.gz -C /usr/local/bin

cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF



curl -L https://github.com/containerd/nerdctl/releases/download/v${NETCTL_VERSION}/nerdctl-full-${NETCTL_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/nerdctl-full.tar.gz
tar Cxzvvf /usr/local /tmp/nerdctl-full.tar.gz

mkdir -p /etc/nerdctl
cat > /etc/nerdctl/nerdctl.toml <<EOF
debug          = false
debug_full     = false
address        = "unix:///run/containerd/containerd.sock"
namespace      = "k8s.io"
snapshotter    = "stargz"
cgroup_manager = "cgroupfs"
hosts_dir      = ["/etc/containerd/certs.d", "/etc/docker/certs.d"]
experimental   = true
EOF

# TODO
# 安装boltbrowser用于调试containerd /var/lib/containerd/io.containerd.metadata.v1.bolt/meta.db
# go install github.com/br0xen/boltbrowser@latest