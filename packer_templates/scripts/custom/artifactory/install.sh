#!/bin/bash

set -e
set -x


injectScript="./inject.exp"

# 检查系统中是否已安装 Expect
if ! command -v expect &> /dev/null; then
    echo "Expect 未安装，正在安装..."

    # 根据系统类型使用适当的包管理器进行安装
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
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

# 检查容器是否存在
if docker inspect artifactory  &> /dev/null; then
    echo "容器已经存在"
else
    echo "容器不存在，正在启动..."
    # 运行容器的命令
    docker run --name artifactory --restart always -v /data/jfrog/var/:/var -d -v /etc/localtime:/etc/localtime -p 28081:8081 -p 28082:8082 
    
fi

cat  << 'EOF' > $injectScript

#!/usr/bin/expect -f

# 设置超时时间
set timeout 30

log_file jfrog.license

# 运行目标程序并等待它请求输入
spawn docker exec  -it -u root artifactory   /opt/jfrog/artifactory/app/third-party/java/bin/java -jar /var/artifactory-injector-1.1.jar

# 匹配程序输出中的特定字符串，然后发送相应的响应
expect "What do you want to do?\n1 - generate License String\n2 - inject artifactory\n"
send "2\r"

expect "where is artifactory home? (\"back\" for back)"
send "/opt/jfrog/artifactory/app/artifactory/tomcat\r"

expect "artifactory detected. continue? (yes/no)"
send "yes\r"

expect "What do you want to do?\n1 - generate License String\n2 - inject artifactory\n"
send "1\r"




#set output_file "jfrog.license"
#set fh [open $output_file "w"]
#puts $fh $random_string
#close $fh
# print license
#puts "license: $random_string"

expect "artifactory detected. continue? (yes/no)"
send "\r"

expect "What do you want to do?\n1 - generate License String\n2 - inject artifactory\n"
send "exit\r"

# 等待程序执行完成并输出结果
expect eof


EOF
chmod +x "$injectScript"

# 循环执行docker log命令并检测目标字符串
while :
do
    ret=`curl --proxy "" -sS "http://127.0.0.1:28082/access/api/v1/system/ping"`
    if [ $ret = "OK" ]  ; then
        echo "service start"
        # 执行Expect脚本
        output=$(expect $injectScript)
        break
    fi

    # 等待一段时间后继续循环（可根据需要调整等待时间）
    echo "waiting for service start"
    sleep 20
done

# 删除临时文件
rm -f $injectScript
docker restart artifactory