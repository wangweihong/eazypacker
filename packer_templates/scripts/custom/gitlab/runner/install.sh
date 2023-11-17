
#!/bin/bash
set -e
set -x

# TODO: support other os

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt update
sudo apt-get install gitlab-runner -y