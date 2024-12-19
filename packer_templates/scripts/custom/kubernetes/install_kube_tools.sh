#!/bin/bash
set -e
set -x

KUBE_VERSION=${KUBE_VERSION:-1.30.0}
KUBE_ARCH=${OS_ARCH:-amd64}

function install_tools_ubuntu_noproxy() {
    case "${KUBE_VERSION}" in
    1.30.* | 1.29.* | 1.28.* | 1.27.* | 1.26.*)
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        # containerd rely on kernel > 4.11
        case "${OS_VERSION}" in
        16.04)
            echo "version:${KUBE_VERSION} no support in os ${OS_VERSION}, exit"
            exit 1
            ;;
        esac
        #   20.04
        majorVersion=$(echo ${KUBE_VERSION} | cut -d '.' -f 1,2)
        mkdir -p /etc/apt/keyrings
        curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -g
        sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        ;;
    *)
        echo "not support kubernetes version ${KUBE_VERSION}, exit installation"
        exit 1
        ;;
    esac
}

function install_tools_ubuntu() {

    case "${KUBE_VERSION}" in
    1.18.*)
        sudo apt-get update
        sudo apt-get install -y curl
        curl -L https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl -o /usr/bin/kubectl
        chmod +x /usr/bin/kubectl
        curl -L https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubelet -o /usr/bin/kubelet
        chmod +x /usr/bin/kubelet
        curl -L https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubeadm -o /usr/bin/kubeadm
        chmod +x /usr/bin/kubeadm
        mkdir -p /etc/systemd/system/kubelet.service.d/
        cat >/etc/systemd/system/kubelet.service.d/10-kubeadm.conf <<'EOF'
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
EOF
        ;;
    1.30.* | 1.29.* | 1.28.* | 1.27.* | 1.26.*)
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl
        # containerd rely on kernel > 4.11
        case "${OS_VERSION}" in
        16.04)
            echo "version:${KUBE_VERSION} no support in os ${OS_VERSION}, exit"
            exit 1
            ;;
        esac
        #   16.04
        majorVersion=$(echo ${KUBE_VERSION} | cut -d '.' -f 1,2)
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v${majorVersion}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${majorVersion}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        ;;
    *)
        echo "not support kubernetes version ${KUBE_VERSION}, exit installation"
        exit 1
        ;;
    esac
}

function install_tools_rockylinux() {
# # dnf install -y yum-utils
# # yum-config-manager --add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
# # sed -i -e 's/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo
# # dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# # cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm/
# enabled=1
# gpgcheck=1
# gpgkey=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
# exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
# EOF
# # yum install kubeadm-1.30.0-150500.1.1.x86_64 kubelet-1.30.0-150500.1.1.x86_64 kubectl --disableexcludes=kubernetes
    # 如果containernd版本不兼容，需要清理 
    # 
    case "${KUBE_VERSION}" in
    1.30.*)
        cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
        dnf makecache
        # 需要指定安装的架构
        sudo dnf install -y kubeadm.`uname -m` kubectl.`uname -m` kubelet.`uname -m` --disableexcludes=kubernetes
        ;;
    *)
        echo "not support kubernetes version ${KUBE_VERSION}, exit installation"
        exit 1
        ;;
    esac
}

function install_tools_package_management() {
    case "${OS_NAME}" in
    ubuntu)
        install_tools_ubuntu
        ;;
    rockylinux)
        install_tools_manually_rockylinux
        ;;   
    *)
        echo "not support kubernetes install in os ${OS_NAME}, exit installation"
        exit 1
        ;;
    esac
}

function install_tools_manual() {
    curl -L "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl" -o /tmp/kubectl
    sudo install -o root -g root -m 0755 /tmp/kubectl /usr/bin/kubectl
    curl -L "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubeadm" -o /tmp/kubeadm
    sudo install -o root -g root -m 0755 /tmp/kubeadm /usr/bin/kubeadm
    curl -L "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubelet" -o /tmp/kubelet
    sudo install -o root -g root -m 0755 /tmp/kubelet /usr/bin/kubelet

    mkdir -p /etc/systemd/system/kubelet.service.d/
    cat >/etc/systemd/system/kubelet.service.d/10-kubeadm.conf <<'EOF'
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
EOF
}


echo "install kubernetes tools, version:${KUBE_VERSION},arch:${KUBE_ARCH}"
#install_tools_manual
install_tools_package_management
