#!/usr/bin/env bash
set -ex

apt install -y bash-completion
sudo sh -c 'kubeadm completion bash > /etc/bash_completion.d/kubeadm'
sudo sh -c 'kubectl completion bash > /etc/bash_completion.d/kubectl'
sudo sh -c 'crictl completion > /etc/bash_completion.d/crictl'

echo " " >> /root/.bashrc
echo "source /etc/bash_completion" >> /root/.bashrc
# echo "source <(kubectl completion bash)" >> /root/.bashrc


echo "install kubernetes kubectl-convert"
curl -LO "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl-convert"
sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert

# kubectl convert -f beta-ingress.yaml --output-version networking.k8s.io/v1