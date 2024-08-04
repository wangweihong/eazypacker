#!/bin/bash
set -ex

function install_youdaoyun(){
    url=https://cowork-common-public-cdn.lx.netease.com/artifact%2F2024%2F07%2F16%2F3144a669.deb?Signature=vJWIQRoWyagOr8UOQlh3I2%2F6fb1KK6ZbISj%2FLPjoBrM%3D&Expires=1722797810&NOSAccessKeyId=88907de754f02ec4890b8d4499c5a8e5
    curl -L ${url} -o youdaoyun.deb
    sudo dkpg -i youdaoyun.deb
}

# 拼音输入法
function install_fcitx_pinyin_input(){
    sudo apt install -y fcitx5  \
            fcitx5-chinese-addons \
            fcitx5-frontend-gtk3 \
            fcitx5-frontend-gnome3 \
            kde-config-fcitx5 \
            fcitx-frontend-qt5 \
            gnome-tweaks

    # 使用im-config，设置fcitx为默认输入法
   curl -L https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-20240509.dict -o zhwiki-20240509.dict
   mkdir -p  ~/.local/share/fcitx5/pinyin/diectionaries/
   mv zhwiki-20240509.dict  ~/.local/share/fcitx5/pinyin/diectionaries/
}

# 不要用应用商店里面的vscode, 功能有阉割
function install_vscode(){
    url=https://vscode.download.prss.microsoft.com/dbazure/download/stable/b1c0a14de1414fcdaa400695b4db1c0799bc3124/code_1.92.0-1722473020_amd64.deb
    curl -L ${url} -o vscode.deb
    sudo dkpg -i vscode.deb
}

# 同步时钟
timedatectl set-local-rtc 1
apt install -y git
