#!/bin/bash
set -e
set -x



sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# 注意wget也要代理
#wget -e use_proxy=yes -e http_proxy=${HTTP_PROXY} -e https_proxy=${HTTPS_PROXY}  https://packages.cloud.google.com/apt/doc/apt-key.gpg -O /root/kubernetes-archive-keyring.gpg
wget -e use_proxy=yes  https://packages.cloud.google.com/apt/doc/apt-key.gpg -O /root/kubernetes-archive-keyring.gpg
mkdir -p /usr/share/keyrings
mv /root/kubernetes-archive-keyring.gpg /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y  --allow-unauthenticated kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00 
sudo apt-mark hold kubelet kubeadm kubectl