#!/bin/bash
set -e
set -x

OS_NAME=${OS_NAME:-"ubuntu"}
OS_VERSION=${OS_VERSION:-"20.04"}
KUBE_VERSION=${KUBE_VERSION:-1.30.0}
KUBE_ARCH=${KUBE_ARCH:-amd64}
CONTAINTERD_VERSION=${CONTAINTERD_VERSION:-1.7.16}
RUNC_VERSION=${RUNC_VERSION:-1.2.0-rc.1}
CNI_VERSION=${CNI_VERSION:-1.4.1}

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
    *) ;;
    esac
    e
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
        exit 1
        ;;
    esac
}

function config_containerd() {
    case "${OS_NAME}" in
    ubuntu)
        case "${OS_VERSION}" in
        22.* | 24.*) 
            # 见 https://github.com/etcd-io/etcd/issues/13670
            # 在ubuntu 24.04环境中, kubeadm部署的etcd容器会一直不停的收到kill信号，导致集群一直无法正常部署
            # https://kubernetes.io/docs/concepts/architecture/cgroups/  提到某些新的发行版本已经采用了cgroup v2版本
            # ubuntu从21.10版本开始已经默认启用了cgroup v2
            # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd 提到
            # 如果使用cgroupv2, 则建议使用system group
            sed -i 's/SystemdCgroup\s*=\s*false/SystemdCgroup = true/' /etc/containerd/config.toml
        ;;

        esac
        ;;
    *)
        echo "not support containerd in os ${OS_NAME}, exit installation"
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

config_containerd
install_contained_manual
systemctl daemon-reload
systemctl enable containerd --now
