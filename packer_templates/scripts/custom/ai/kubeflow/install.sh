#!/bin/bash
set -ex

sudo sysctl fs.inotify.max_user_instances=2280
sudo sysctl fs.inotify.max_user_watches=1255360

git clone https://github.com/kubeflow/manifests.git
cd ./manifests
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 20; done