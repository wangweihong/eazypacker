#!/bin/bash
set -e 
set -x

case "$OS_NAME" in
ubuntu|debian)
    apt install -y vim
    # disk usage statistics
    apt install -y ncdu
    # cpu/memory usage statistics
    apt install -y htop
    ;;
# centos|rhel)
#     yum -y install bash-completion
#     ;;
 *)    
    echo "not support os ${OS_NAME}" 
    exit 1
    ;;
esac