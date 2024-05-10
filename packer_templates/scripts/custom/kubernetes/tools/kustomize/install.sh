#!/usr/bin/env bash
set -e
set -x

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" -o /tmp/install_kustomize.sh
chmod +x /tmp/install_kustomize.sh
/tmp/install_kustomize.sh ${KUSTOMIZE_VERSION} 
sudo install -o root -g root -m 0755  kustomize /usr/local/bin/kustomize
rm kustomize 