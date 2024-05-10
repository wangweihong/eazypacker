#!/bin/bash
set -e
set -x

function create_newer_release_kubernetes_install_scripts() {
    # 'EOF'关闭转义
    cat >/etc/kubetool/install_kube_master.sh <<EOF
#!/bin/bash
set -e
set -x 

# newer system doesn't has ifconfig
if command -v ifconfig &> /dev/null; then
    localIP=$(ifconfig eth0 | awk '/inet /{print $2}' | cut -d':' -f2)
else
    localIP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
fi

# 设置kubernetes集群的Pod子网, 必须设置calico custom-resource的子网配置和kubernetes一致
sed -i 's#cidr: 192\.168\.0\.0/16#cidr: ${POD_SUBNET}#'  /etc/kubetool/calico/custom-resources.yaml

kubeadm init --apiserver-advertise-address=\$localIP --pod-network-cidr=${POD_SUBNET} --kubernetes-version=$KUBE_VERSION

export KUBECONFIG=/etc/kubernetes/admin.conf

# install network plugins
# trigera-oprator.yaml的注释太长，导致kubectl处理失败。因此需要加上--server-side, 跳过kubectl语法检测        
kubectl apply -f /etc/kubetool/calico/tigera-oprator.yaml --server-side
kubectl apply -f /etc/kubetool/calico/custom-resources.yaml
EOF

}

function create_legacy_release_kubernetes_install_script() {
    # 'EOF'关闭转义
    cat >/etc/kubetool/install_kube_master.sh <<EOF
#!/bin/bash
set -e
set -x

# newer system doesn't has ifconfig
if command -v ifconfig &> /dev/null; then
    localIP=\$(ifconfig eth0 | awk '/inet /{print \$2}' | cut -d':' -f2)
else
    localIP=\$(ip -4 addr show eth0 | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}')
fi


kubeadm init --apiserver-advertise-address=\$localIP  --kubernetes-version=$KUBE_VERSION

export KUBECONFIG=/etc/kubernetes/admin.conf

# install network plugins
kubectl apply -f /etc/kubetool/calico/calico.yaml
EOF
}

function create_kubernetes_post_install_config_script() {
    cat >/etc/kubetool/config_kube_master.sh <<EOF
#!/bin/bash
set -e
set -x 

export KUBECONFIG=/etc/kubernetes/admin.conf
# install network plugins
/etc/kubetool/install_cni_network.sh

# new version change tain to control-plane
kubectl taint nodes --all node-role.kubernetes.io/master- || true
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

echo " " >> /root/.bashrc
echo "source /etc/bash_completion" >> /root/.bashrc
echo "source <(kubectl completion bash)" >> /root/.bashrc


# disable auto install service
systemctl disable install_kubernetes_once || true
EOF
}

case "${KUBE_VERSION}" in
1.30.* | 1.29.* | 1.28.* | 1.27.* | 1.26.* | 1.25.* | 1.24.* | 1.23.* | 1.22.* | 1.21.* | 1.20.*)
    #    CALICO_VERSION=v3.27.3

    mkdir -p /etc/kubetool/
    mkdir -p /etc/kubetool/calico
    curl -L https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml -o /etc/kubetool/calico/tigera-oprator.yaml
    curl -L https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml -o /etc/kubetool/calico/custom-resources.yaml
    create_newer_release_kubernetes_install_scripts
    create_kubernetes_post_install_config_script
    ;;
*)
    mkdir -p /etc/kubetool/
    mkdir -p /etc/kubetool/calico
    curl -L https://docs.projectcalico.org/archive/v3.14/manifests/calico.yaml -o /etc/kubetool/calico/calico.yaml
    create_legacy_release_kubernetes_install_script
    create_kubernetes_post_install_config_script
    ;;
esac

chmod +x /etc/kubetool/install_kube_master.sh

# if custom master image, enable auto install service
# "${KUBE_WORKER+isset}" = "isset" 是为了避免IS_MASTER没有设置时直接出错，而非判定为false
if [ "${KUBE_WORKER+isset}" = "isset" ] && [ "${KUBE_WORKER}" = "true" ]; then
    echo "current is worker node image, skip create install_kubernetes_once.service"
else

    # /etc/systemd/system/install_kubernetes_once.service
    cat >/etc/systemd/system/install_kubernetes_once.service <<'EOF'
[Unit]
Description=Run Install Kubernetes Once Script
After=network-online.target
Requires=network-online.target

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
