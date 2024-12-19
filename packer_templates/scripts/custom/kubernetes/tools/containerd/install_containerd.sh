#!/bin/bash
set -e
set -x

KUBE_VERSION=${KUBE_VERSION:-1.30.0}
KUBE_ARCH=${OS_ARCH:-amd64}
CONTAINTERD_VERSION=${CONTAINTERD_VERSION:-1.7.16}

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

function clean_old_version() {
    case "${OS_NAME}" in
    ubuntu)
        sudo apt-get remove docker docker-engine docker.io containerd runc || tru
        ;;
    rockylinux)
        dnf remove containerd containernetworking-plugins
        ;;
    *) ;;
    esac
    e
}

function install_tools_ubuntu() {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install containerd.io=${CONTAINTERD_VERSION}-1
}

function install_tools_rockylinux() {
    dnf install -y yum-utils
    yum-config-manager --add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
    sed -i -e 's/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo
    dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

function install_tools_package_management() {
    case "${OS_NAME}" in
    ubuntu)
        install_tools_ubuntu
        ;;
    rockylinux)
        install_tools_rockylinux
        ;;
    *)
        echo "not support kubernetes install in os ${OS_NAME}, exit installation"
        exit 1
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

if command -v containerd >/dev/null 2>&1; then
    exist_version=$(containerd --version | awk '{print $3}')
    if [ ${exist_version} != ${CONTAINTERD_VERSION}]; then
        clean_old_version
    else
        echo "Containerd version ${CONTAINTERD_VERSION} has exist, skip installing"

        systemctl daemon-reload
        systemctl enable containerd --now
        exit 0
    fi

fi

install_contained_manual

systemctl daemon-reload
systemctl enable containerd --now
