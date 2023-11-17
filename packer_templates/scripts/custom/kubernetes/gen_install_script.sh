#!/bin/bash
set -e
set -x

mkdir -p /etc/kubetool/

# 'EOF'关闭转义
cat > /etc/kubetool/install_kube_master.sh << 'EOF'
localIP=`/sbin/ifconfig eth0 | awk -F ' *|:' '/inet addr/{print $4}'`

kubeadm init --apiserver-advertise-address=$localIP

export KUBECONFIG=/etc/kubernetes/admin.conf

# install network plugins
kubectl apply -f https://docs.projectcalico.org/archive/v3.14/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
EOF

chmod +x /etc/kubetool/install_kube_master.sh