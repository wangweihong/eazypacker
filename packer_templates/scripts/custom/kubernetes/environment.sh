#!/bin/bash
set -ex

# 全局必配置变量
export OS_ARCH=${OS_ARCH:-"x86_64"}
export OS_NAME=${OS_NAME:-"ubuntu"}
export OS_VERSION=${OS_VERSION:-"20.04"}
export KUBE_VERSION=${KUBE_VERSION:-1.30.0}
export KUBE_ARCH=${KUBE_ARCH:-amd64}
export KUBE_WORKER=${KUBE_WORKER:false}
export HELM_VERSION=${HELM_VERSION:-3.13.2}
export KUSTOMIZE_VERSION=${KUSTOMIZE_VERSION:-5.4.1}
export KUBE_TOOL_ROOT=${KUBE_TOOL_ROOT:-/etc/kubetool}

if [ "${KUBE_ARCH}" = "x86_64" ]; then
    export KUBE_ARCH="amd64"
fi

mkdir -p ${KUBE_TOOL_ROOT}

# see https://containerd.io/releases/ for version compatibility
case "${KUBE_VERSION}" in
1.30.*)
    # change version when stable release
    # CONTAINTERD_VERSION=2.0.0-rc.1
    export CONTAINTERD_VERSION=${CONTAINTERD_VERSION:-1.7.16}
    export RUNC_VERSION=${RUNC_VERSION:-1.2.0-rc.1}
    export CNI_VERSION=${CNI_VERSION:-1.4.1}
    export NETCTL_VERSION=${NETCTL_VERSION:-2.0.0-beta.5}
    export POD_SUBNET=${POD_SUBNET:-172.18.0.0/16}
    export CALICO_VERSION=${CALICO_VERSION:-v3.27.3}
    # crictl版本和kubernetes版本保持一致
    export CRICTL_VERSION=${KUBE_VERSION:-1.30.0}
    export KUBE_CRI=${KUBE_CRI:-containerd}
    ;;
1.29.*)
    export CONTAINTERD_VERSION=${CONTAINTERD_VERSION:-1.7.11}
    export RUNC_VERSION=${RUNC_VERSION:-1.2.0-rc.1}
    export CNI_VERSION=${CNI_VERSION:-1.4.1}
    export NETCTL_VERSION=${NETCTL_VERSION:-2.0.0-beta.5}
    export POD_SUBNET=${POD_SUBNET:-172.18.0.0/16}
    export CALICO_VERSION=${CALICO_VERSION:-v3.27.3}
    export CRICTL_VERSION=${KUBE_VERSION:-1.29.0}
    export KUBE_CRI=${KUBE_CRI:-containerd}
    ;;
1.28.* | 1.27.* | 1.26.* | 1.25.*)
    export CONTAINTERD_VERSION=${CONTAINTERD_VERSION:-1.7.0}
    export RUNC_VERSION=${RUNC_VERSION:-1.2.0-rc.1}
    export CNI_VERSION=${CNI_VERSION:-1.4.1}
    export NETCTL_VERSION=${NETCTL_VERSION:-2.0.0-beta.5}
    export POD_SUBNET=${POD_SUBNET:-172.18.0.0/16}
    export CALICO_VERSION=${CALICO_VERSION:-v3.27.3}
    export CRICTL_VERSION=${KUBE_VERSION:-1.28.0}
    export KUBE_CRI=${KUBE_CRI:-containerd}
    ;;
*)
    export CALICO_VERSION=${CALICO_VERSION:-v3.14}
    export KUBE_CRI=${KUBE_CRI:-docker}
    ;;
esac

case "${KUBE_VERSION}" in

1.30.* | 1.29.* | 1.28.* | 1.27.* | 1.26.*)
    case "${OS_VERSION}" in
    16.04)
        #   containerd rely on kernel version > 4.11
        echo "version:${KUBE_VERSION} no support in os ${OS_NAME}/${OS_VERSION}, exit"
        exit 1
        ;;
    esac
    ;;
esac
