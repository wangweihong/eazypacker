#!/usr/bin/env bash
set -e
set -x

# fix error below
# Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
# Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
sudo pkill apt  || true
sudo pkill apt-get || true

sudo apt-get remove docker docker-engine docker.io containerd runc

# use alicloud apt source instead
# 使用ubuntu源时，这里访问极其缓慢，因此采用阿里云源来替代
if [ -n "${USE_ALICLOUD}" ] && [ "${USE_ALICLOUD}" = "true" ] ; then 
  echo "use alicloud apt source"
  sudo apt-get update
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get -y update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io

else 

sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi
# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
