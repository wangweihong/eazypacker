#!/bin/sh -eux

# 在env_reset下加一行'Defaults  exempt_group=sudo'
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;

# Set up password-less sudo for the vagrant user
# 允许vagrant用户在不输密码的情况下以任意用户的身份执行任意操作
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant;
chmod 440 /etc/sudoers.d/99_vagrant;
