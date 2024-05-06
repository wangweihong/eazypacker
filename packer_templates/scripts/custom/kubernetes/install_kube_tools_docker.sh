#!/bin/bash
set -e
set -x

function install_cri_dockerd() {
    curl -L   https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.13/cri-dockerd-0.3.13.amd64.tgz -o cri-dockerd.tgz
    tar xvzf /tmp/cri-dockerd.tgz
    install -o root -g root -m 0755 /tmp/cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
    sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
    systemctl daemon-reload
    systemctl enable --now cri-docker.socket
}

KUBE_RELEASE=1.18.0
KUBE_ARCH=amd64

if [ "${KUBERNETES_VERSION+isset}" = "isset" ]; then
    KUBE_RELEASE=${KUBERNETES_VERSION}
fi

echo "install kubernetes release, version:${KUBE_RELEASE},arch:${KUBE_ARCH}"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

case "${KUBE_RELEASE}" in
1.18.0)
    case "${OS_VERSION}" in
    16.04)
        mkdir -p /usr/share/keyrings
        wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -O /usr/share/keyrings/kubernetes-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        ;;
    20.04)
        rm /etc/apt/trusted.gpg.d/kubernetes.gpg || true
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        ;;
    *)
        echo "not support os version ${OS_NAME}-${OS_VERSION}, exit  installation"
        exit 1
        ;;
    esac

    sudo apt-get update
    sudo apt-get install -y --allow-unauthenticated kubelet=${KUBE_RELEASE}-00 kubeadm=${KUBE_RELEASE} kubectl=${KUBE_RELEASE}
    sudo apt-mark hold kubelet kubeadm kubectl
    ;;
1.30)
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBE_RELEASE}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    install_cri_dockerd
    ;;
*)
    echo "not support kubernetes version ${KUBE_RELEASE}, exit  installation"
    exit 1
    ;;
esac
