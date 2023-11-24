#!/bin/bash
set -e
set -x

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

case "${OS_VERSION}" in
16.04)
    mkdir -p /usr/share/keyrings
    wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -O /usr/share/keyrings/kubernetes-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.lis
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
sudo apt-get install -y --allow-unauthenticated kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00
sudo apt-mark hold kubelet kubeadm kubectl
