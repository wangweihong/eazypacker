#!/bin/bash
set -e
set -x

echo "install kubernetes release cri containerd, version:${KUBE_VERSION},arch:${KUBE_ARCH}"

function install_contained_manual() {
    curl -L https://github.com/containerd/containerd/releases/download/v${CONTAINTERD_VERSION}/containerd-${CONTAINTERD_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/containerd.tar.gz
    tar Cxzvf /usr/local /tmp/containerd.tar.gz

    curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /lib/systemd/system/containerd.service
    systemctl daemon-reload
    systemctl enable --now containerd

    curl -L https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${KUBE_ARCH} -o /usr/local/sbin/runc
    chmod 755 /usr/local/sbin/runc

    mkdir -p /opt/cni/bin
    curl -L https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-${KUBE_ARCH}-v${CNI_VERSION}.tgz -o /tmp/cni-plugins.tgz
    tar Cxzvf /opt/cni/bin /tmp/cni-plugins.tgz

    mkdir -p /etc/containerd
    containerd config default >/etc/containerd/config.toml
}

function install_tools_ubuntu() {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl

}

function install_tools_package_management() {
    case "${OS_NAME}" in
    ubuntu)
        install_tools_ubuntu
        ;;
    *)
        echo "not support kubernetes install in os ${OS_NAME}, exit installation"
        exit1
        ;;
    esac
}

if ! command -v curl >/dev/null 2>&1; then
    case "${OS_NAME}" in
    ubuntu)
        sudo apt-get update
        sudo apt-get install -y curl
        ;;
    *)
        echo "not support containerd install in os ${OS_NAME}, exit installation"
        exit 1
        ;;
    esac
fi

install_contained_manual

systemctl daemon-reload
systemctl enable containerd --now

curl -L https://github.com/containerd/nerdctl/releases/download/v${NETCTL_VERSION}/nerdctl-full-${NETCTL_VERSION}-linux-${KUBE_ARCH}.tar.gz -o /tmp/nerdctl-full.tar.gz
tar Cxzvvf /usr/local /tmp/nerdctl-full.tar.gz
