#!/bin/sh -eux
export DEBIAN_FRONTEND=noninteractive

# 获取ubuntu的版本
ubuntu_version=$(lsb_release -r | awk '{ print $2 }')
major_version="$(echo "$ubuntu_version" | awk -F. '{print $1}')";

if [ "$major_version" -ge "18" ]; then
    echo "disable release-upgrades"
    sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

    # 关闭掉ubuntu系统自动更新和升级服务。这会导致系统启动很慢
    echo "disable systemd apt timers/services"
    systemctl stop apt-daily.timer
    systemctl stop apt-daily-upgrade.timer
    systemctl disable apt-daily.timer
    systemctl disable apt-daily-upgrade.timer
    systemctl mask apt-daily.service
    systemctl mask apt-daily-upgrade.service
    systemctl daemon-reload

    # Disable periodic activities of apt to be safe
    cat <<EOF >/etc/apt/apt.conf.d/10periodic
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

fi

# 无人值守自动更新功能, 会在后台自动下载和安装系统更新文件, 会阻止关机。且导致系统开机非常慢
echo "remove the unattended-upgrades and ubuntu-release-upgrader-core packages"
rm -rf /var/log/unattended-upgrades
apt-get -y purge unattended-upgrades ubuntu-release-upgrader-core

echo "update the package list"
apt-get -y update

echo "upgrade all installed packages incl. kernel and kernel headers"
apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

reboot
