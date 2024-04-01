#!/bin/bash
set -e
set -x


# 检查系统中是否已安装 Expect
if ! [ -x "$(command -v expect)" ]; then
    echo "Expect 未安装，正在安装..."

    # 根据系统类型使用适当的包管理器进行安装
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y expect
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y expect
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y expect
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Sy --noconfirm expect
    else
        echo "无法确定包管理器，请手动安装 Expect。"
        exit 1
    fi
fi