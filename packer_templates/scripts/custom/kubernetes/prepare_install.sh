#!/bin/bash
set -e
set -x

function config_docker_daemon() {
  cat >/etc/docker/daemon.json <<EOF
{
        "max-concurrent-downloads": 10,
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
                "max-size": "100m"
        },
        "storage-driver": "overlay2"
}
EOF
  systemctl daemon-reload
  systemctl restart docker
}

function pull_required_images() {

  case "${KUBE_VERSION}" in
  1.30.* | 1.29.* | 1.28.* | 1.27.* | 1.26.*)
    curl -L https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml -o /tmp/calico.yaml
    # 从yaml中提取所有的镜像
    # 注意不要用containers[*],会报Error: '.' expects 2 args but there is 1

    tigera_oprator_image=$(yq eval-all '.spec.template.spec.containers[].image' /tmp/calico.yaml)
    # 新版的calico镜像的数据内置在tigera_operator_image内,无法通过yq解析yaml获取
    calico_images=(
      docker.io/calico/apiserver:${CALICO_VERSION}
      docker.io/calico/apiserver:${CALICO_VERSION}
      docker.io/calico/cni:${CALICO_VERSION}
      docker.io/calico/csi:${CALICO_VERSION}
      docker.io/calico/kube-controllers:${CALICO_VERSION}
      docker.io/calico/node-driver-registrar:${CALICO_VERSION}
      docker.io/calico/node:${CALICO_VERSION}
      docker.io/calico/pod2daemon-flexvol:${CALICO_VERSION}
      docker.io/calico/typha:${CALICO_VERSION}
    )

    # 1.30 默认使用containerd引擎
    # 获取kubeadm config images list列出的所有镜像列表, 并通过ctr拉取
    # 注意: kubeadm无法再通过参数指定pause镜像, 2
    ns=k8s.io
    images_list=$(kubeadm config images list --kubernetes-version=${KUBE_VERSION})
    echo "$images_list" | while IFS= read -r image; do
      ctr -n ${ns} images pull "$image"
    done

    # https://github.com/kubernetes/kubeadm/issues/2020
    # kubeadm已不会去设置 containerd的sandbox
    if [ -e /etc/containerd/config.toml ]; then
      sanboxImage=$(grep -oP 'sandbox_image\s*=\s*"\K[^"]+' /etc/containerd/config.toml)
      ctr -n ${ns} images pull ${sanboxImage}
    fi

    echo "pull images $tigera_oprator_image"
    for image in $tigera_oprator_image; do
      if [ $image != "---" ]; then
        echo "pull image $image"
        ctr -n ${ns} images pull "$image"
      fi
    done

    echo "pull images $calico_images"
    for image in $calico_images; do
      if [ $image != "---" ]; then
        echo "pull image $image"
        ctr -n ${ns} images pull "$image"
      fi
    done
    ;;

  *)
    # 拉取网络插件相关镜像
    curl -L https://docs.projectcalico.org/archive/${CALICO_VERSION}/manifests/calico.yaml -o /tmp/calico.yaml
    # 从yaml中提取所有的镜像
    # 注意不要用containers[*],会报Error: '.' expects 2 args but there is 1
    calico_images=$(yq eval-all '.spec.template.spec.containers[].image' /tmp/calico.yaml)

    # 配置docker daemon
    config_docker_daemon
    # 先尝试拉取k8s 镜像
    kubeadm config images pull --kubernetes-version=${KUBE_VERSION}

    for image in $calico_images; do
      if [ $image != "---" ]; then
        echo "pull image $image"
        docker pull "$image"
      fi
    done
    ;;
  esac
}

case "${OS_NAME}" in
ubuntu)
  sudo apt-get update
  sudo apt-get install -y socat
  sudo apt-get install -y conntrack
  sudo apt-get install -y iptables
  sudo apt-get install -y ebtables
  # for kubectl completion
  sudo apt install -y bash-completion
  ;;
*)
  echo "not support system tool install in os ${OS_NAME}, exit installation"
  exit 1
  ;;
esac

# 'EOF'关闭转义
cat >/usr/bin/kubelet-pre-start.sh <<'END'
#!/bin/bash
# Open ipvs
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
if [[ $(uname -r | cut -d . -f1) -ge 4 && $(uname -r | cut -d . -f2) -ge 19 ]]; then
  modprobe -- nf_conntrack
else
  modprobe -- nf_conntrack_ipv4
fi

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
sysctl -w net.ipv4.ip_forward=1
# systemctl stop firewalld && systemctl disable firewalld
#  注意, swapoff -a不完全可行, 如果/etc/fstab存在swap分区的配置的话, 即使执行了swapoff -a, 间隔一段时间swap又会启动
#  通过cat /proc/swaps 确认swap是否启动
swapoff -a

if command -v setenforce >/dev/null 2>&1; then
  setenforce 0 || true
fi
exit 0
END

chmod +x /usr/bin/kubelet-pre-start.sh

# 'EOF'关闭转义
cat >/lib/systemd/system/kubelet.service <<'EOF'
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
ExecStartPre=/usr/bin/kubelet-pre-start.sh
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet


echo "config kubernetes prepare install, version:${KUBE_VERSION},arch:${KUBE_ARCH}"
pull_required_images
