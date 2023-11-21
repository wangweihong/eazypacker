#!/bin/bash
set -e
set -x

export PATH=/usr/local/bin:$PATH

# if using systemd, make sure /usr/bin/systemctl exists
if command -v systemctl &>/dev/null; then
    if [ ! -e /usr/bin/systemctl ]; then
        ln -s $(which systemctl) /usr/bin/systemctl
    fi
fi

# 如果 K3S_EXEC_ARGS 变量未定义或为空，那么它将被赋值为等号后面的默认值
#: ${K3S_EXEC_ARGS:="-disable=local-storage,metrics-server --disable-cloud-controller --disable-network-policy --flannel-backend=host-gw --log=/var/log/k3s.log"}

mkdir -p /etc/rancher/k3s
# TODO: using INSTALL_K#S_EXEC cause image build always fails
#curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC="${K3S_EXEC_ARGS}" sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_MIRROR=cn sh -

mkdir -p /etc/kubernetes
ln -s /etc/rancher/k3s/k3s.yaml /etc/kubernetes/admin.conf

# fix bash completion '_get_comp_words_by_ref: command not found' error
case "$OS_NAME" in
ubuntu|debian)
    apt install bash-completion
    ;;
centos|rhel)
    yum -y install bash-completion
    ;;
 *)    
    echo "not support os name, skip bash-completion installation" 
    ;;
esac

mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

echo " " >> /root/.bashrc
echo "source <(kubectl completion bash)" >> /root/.bashrc