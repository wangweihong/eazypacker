#!/bin/bash
set -e
set -x

# function install_cri_dockerd() {
#     curl -L   https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.13/cri-dockerd-0.3.13.amd64.tgz -o cri-dockerd.tgz
#     tar xvzf /tmp/cri-dockerd.tgz
#     install -o root -g root -m 0755 /tmp/cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
#     wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
#     wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
#     sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
#     systemctl daemon-reload
#     systemctl enable --now cri-docker.socket
# }