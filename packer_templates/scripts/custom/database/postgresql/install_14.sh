#!/bin/bash
set -e
set -x

case "$OS_NAME" in
ubuntu)
    echo "install postgresql-${DATABASE_VERSION} in ubuntu-${OS_VERSION}"
    ;;
*)
    echo "not support os $OS_NAME, exit postgresql installation"
    exit 1
    ;;
esac

if [ $OS_VERSION = "16.04" ]; then
    echo "not suport os version $OS_VERSION"
    exit 1
fi

apt install gnupg gnupg2 gnupg1 -y
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update -y
apt-get install postgresql-14 -y



