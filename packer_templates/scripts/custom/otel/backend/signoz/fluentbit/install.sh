#!/usr/bin/env bash

OS_ARCH=${OS_ARCH:-"x86_64"}
OS_NAME=${OS_NAME:-"ubuntu"}
OS_VERSION=${OS_VERSION:-"20.04"}


function install_tools_ubuntu() {
    case "${OS_VERSION}" in
    20.04)
        curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg
        echo \
        "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/ubuntu/$(lsb_release -cs) $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/fluentbit.list > /dev/null
        sudo apt update -y
        sudo apt-get install fluent-bit -y

        # https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/variables
        # 追加一些变量到默认fluent-bit默认环境变量中, 后续可以在fluent-bit可以通过${var}的方式来使用
        # 通过record_modifier将信息追加到fluent-bit的每条日志项中
        # 
        # 当前fluent运行实例IP
        echo Fluent_IP=`hostname -I | awk '{ print $1 }'` >> /etc/default/fluentbit
        # 生成唯一的UUID, 避免IP漂移
        echo Fluent_ID=`uuidgen` >> /etc/default/fluentbit

        sudo systemctl enable fluent-bit
        sudo systemctl start fluent-bit
        ;;
    *)
        echo "not support install in os ${OS_NAME}/${OS_VERSION}, exit installation"
        exit 1
        ;;
    esac

}

case "${OS_NAME}" in
ubuntu)
    install_tools_ubuntu
    ;;
*)
    echo "not support install in os ${OS_NAME}, exit installation"
    exit 1
    ;;
esac
