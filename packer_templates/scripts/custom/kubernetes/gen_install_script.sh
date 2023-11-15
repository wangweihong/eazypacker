#!/bin/bash
set -e
set -x

mkdir -p /etc/kubetool/
cat > /etc/kubetool/install_kube_master.sh << EOF
localIP=`/sbin/ifconfig ens33 | awk -F ' *|:' '/inet addr/{print $4}'`

kubeadm init --apiserver-advertise-address=$localIP

export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装网络插件
kubectl apply -f https://docs.projectcalico.org/archive/v3.14/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
EOF

