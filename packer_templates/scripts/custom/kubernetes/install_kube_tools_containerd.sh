#!/bin/bash
set -e
set -x

KUBE_RELEASE=1.26.0
CONTAINTERD_VERSION=1.7.0
KUBE_ARCH=amd64
RUNC_VERSION=1.20-rc1
CNI_VERSION=1.4.1

if [ "${KUBERNETES_VERSION+isset}" = "isset" ]; then
    KUBE_RELEASE=${KUBERNETES_VERSION}
fi

echo "install kubernetes release, version:${KUBE_RELEASE},arch:${KUBE_ARCH}"

function install_contained_manual() {
    curl -L https://github.com/containerd/containerd/releases/download/v${CONTAINTERD_VERSION}/containerd-${CONTAINTERD_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/containerd.tar.gz
    tar Cxzvf /usr/local /tmp/containerd.tar.gz

    curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o  /lib/systemd/system/containerd.service
    systemctl daemon-reload
    systemctl enable --now containerd

    curl -L https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${KUBE_ARCH} -o /usr/local/sbin/runc
    chmod 755 /usr/local/sbin/runc

    mkdir -p /opt/cni/bin
    curl -L https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-${KUBE_ARCH}-v${CNI_VERSION}.tgz -o /tmp/cni-plugins.tgz
    tar Cxzvf /opt/cni/bin /tmp/cni-plugins.tgz
}



#sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# check https://containerd.io/releases/ for version compatibility
case "${KUBE_RELEASE}" in
1.30)
    # change version when stable release
    CONTAINTERD_VERSION=2.0.0-rc.1
    ;;
1.29)
    CONTAINTERD_VERSION=1.7.11
    ;;
1.28 | 1.27 | 1.26.*)
    CONTAINTERD_VERSION=1.7.0
    ;;
*)
    echo "cannot find containerd version for kubernetes version ${KUBE_RELEASE}, exit installation"
    exit 1
    ;;
esac

install_contained_manual