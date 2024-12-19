#!/bin/bash
set -e
set -x

function install_tools_ubuntu() {
    case "${OS_VERSION}" in
    20.04)
        echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
        curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key" | sudo apt-key add -
        sudo apt-get update
        sudo apt-get -y upgrade
        sudo apt-get -y install skopeo
        ;;
    20.10 | 22.04)
        sudo apt-get -y update
        sudo apt-get install -y skopeo
        ;;
    *)
        echo "not support skopeo install in os ${OS_NAME}/${OS_VERSION}, exit installation"
        exit 1
        ;;
    esac
}

function install_tools_centos() {
    sudo yum -y install skopeo
}

case "${OS_NAME}" in
ubuntu)
    install_tools_ubuntu
    ;;
centos)
    install_tools_centos
    ;;
*)
    echo "not support skopeo install in os ${OS_NAME}, exit installation"
    exit 1
    ;;
esac
