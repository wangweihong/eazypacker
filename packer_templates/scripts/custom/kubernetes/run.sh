#!/bin/bash
set -ex

SOURCE_ROOT=$(dirname ${BASH_SOURCE[0]})

source ${SOURCE_ROOT}/environment.sh

if [ ${KUBE_CRI} = "containerd" ]; then
    ${SOURCE_ROOT}/install_kube_tools.sh
    ${SOURCE_ROOT}/tools/containerd/install_containerd.sh
    ${SOURCE_ROOT}/tools/containerd/install_cri_tools.sh
    ${SOURCE_ROOT}/tools/containerd/config_proxy.sh
    ${SOURCE_ROOT}/tools/helm/install_helm.sh
    ${SOURCE_ROOT}/tools/kustomize/install.sh
    ${SOURCE_ROOT}/prepare_install.sh
    ${SOURCE_ROOT}/gen_install_script.sh
    ${SOURCE_ROOT}/tools/containerd/cleanup_proxy.sh
else
    ${SOURCE_ROOT}/../ubuntu/install_apt_proxy.sh
    ${SOURCE_ROOT}/../docker/install_docker.sh
    ${SOURCE_ROOT}/../docker/config_docker_proxy.sh
    ${SOURCE_ROOT}/install_kube_tools.sh
    ${SOURCE_ROOT}/tools/helm/install_helm.sh
    ${SOURCE_ROOT}/tools/kustomize/install.sh
    ${SOURCE_ROOT}/prepare_install.sh
    ${SOURCE_ROOT}/gen_install_script.sh
    ${SOURCE_ROOT}/../docker/cleanup_docker_proxy.sh
    ${SOURCE_ROOT}/../ubuntu/cleanup_apt_proxy.sh
fi
