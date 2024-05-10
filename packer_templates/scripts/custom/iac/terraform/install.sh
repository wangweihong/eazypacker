#!/bin/bash
set -e
set -x

if [ $OS_VERSION = "16.04" ] && [ $OS_NAME = "ubuntu"]; then
    echo "not suport os  ${OS_NAME}-${OS_VERSION}"
    exit 1
fi

case "$OS_NAME" in
ubuntu | debian)
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt -y install terraform=${TERRAFORM_VERSION}-1 
    ;;
centos | rhel)
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform-${TERRAFORM_VERSION}
    ;;
*)
    echo "not support os $OS_NAME, exit postgresql installation"
    exit 1
    ;;
esac
