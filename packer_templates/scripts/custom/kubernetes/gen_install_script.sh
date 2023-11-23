#!/bin/bash
set -e
set -x

mkdir -p /etc/kubetool/

# 'EOF'关闭转义
cat >/etc/kubetool/install_kube_master.sh <<'EOF'
#!/bin/bash
set -e
set -x 

# newer system doesn't has ifconfig
if command -v ifconfig &> /dev/null; then
    localIP=$(ifconfig eth0 | awk '/inet /{print $2}' | cut -d':' -f2)
else
    localIP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
fi

kubeadm init --apiserver-advertise-address=$localIP

export KUBECONFIG=/etc/kubernetes/admin.conf

# install network plugins
kubectl apply -f https://docs.projectcalico.org/archive/v3.14/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

echo " " >> /root/.bashrc
echo "source <(kubectl completion bash)" >> /root/.bashrc


# disable auto install service
systemctl disable install_kubernetes_once || true
EOF

chmod +x /etc/kubetool/install_kube_master.sh

# if custom master image, enable auto install service
# "${IS_MASTER+isset}" = "isset" 是为了避免IS_MASTER没有设置时直接出错，而非判定为false
if [ "${IS_MASTER+isset}" = "isset" ] && [ "${IS_MASTER}" = "true" ]; then

    # /etc/systemd/system/install_kubernetes_once.service
    cat >/etc/systemd/system/install_kubernetes_once.service <<'EOF'
[Unit]
Description=Run Install Kubernetes Once Script
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/etc/kubetool/install_kube_master.sh

[Install]
WantedBy=default.target

EOF

    sudo systemctl daemon-reload
    sudo systemctl enable install_kubernetes_once.service

fi
