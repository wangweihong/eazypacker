#!/bin/bash
set -ex

mkdir -p /etc/cloudtool/argocd/
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -O /etc/cloudtool/argocd/install.yaml

# 从yaml中提取所有的镜像
# 注意不要用containers[*],会报Error: '.' expects 2 args but there is 1
images=$(yq eval-all '.spec.template.spec.containers[].image' /etc/cloudtool/argocd/install.yaml)
for image in $images; do
    if [ $image != "---" ]; then
        echo "pull image $image"
        docker pull "$image"
    fi

done

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f /etc/cloudtool/argocd/install.yaml --validate=false
