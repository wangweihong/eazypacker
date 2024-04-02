#!/bin/bash

set -e
set -x


injectScript="/tmp/inject.exp"
licenseFile="/tmp/jfrog.license"

docker run --name artifactory -d \
    --restart always \
    -v /data/jfrog/var/:/var \
    -v /etc/localtime:/etc/localtime \
    -p 28081:8081 -p 28082:8082 \
    releases-docker.jfrog.io/jfrog/artifactory-pro:7.11.5

docker cp /tmp/artifactory-injector-1.1.jar  artifactory:/var/

cat  << EOF > $injectScript

#!/usr/bin/expect -f

# 设置超时时间
set timeout 120
set output_var ""

#log_file jfrog.license

# 运行目标程序并等待它请求输入
spawn docker exec  -it -u root artifactory   /opt/jfrog/artifactory/app/third-party/java/bin/java -jar /var/artifactory-injector-1.1.jar
# 匹配程序输出中的特定字符串，然后发送相应的响应
expect "What do you want to do?\r\n1 - generate License String\r\n2 - inject artifactory\r\nexit - exit\r\n"
send "2\r"
expect "2\r\n"

expect "where is artifactory home? (\"back\" for back)"
send "/opt/jfrog/artifactory/app/artifactory/tomcat\r"

expect "artifactory detected. continue? (yes/no)"
send "yes\r"

expect "What do you want to do?\r\n1 - generate License String\r\n2 - inject artifactory\r\nexit - exit\r\n"
send "1\r"
expect "1\r\n"
# 获取到密钥时, 写到jfrog.license文件中ls
expect "==\r\n" {
        set output_var \$expect_out(buffer)
        set output_file $licenseFile
        set fh [open \$output_file "w"]
        puts \$fh \$output_var
        close \$fh
}

send "\r"


expect "What do you want to do?\r\n1 - generate License String\r\n2 - inject artifactory\r\nexit - exit\r\n"
send "exit\r"

# 等待程序执行完成并输出结果
expect eof


EOF
chmod +x "$injectScript"

# 循环执行docker log命令并检测目标字符串
iterations=10

i=1
while [ $i -le $iterations ]; do
    sleep 20

    ret=`curl --proxy "" -sS "http://127.0.0.1:28082/access/api/v1/system/ping" || true`
    if [ $ret = "OK" ]  ; then
        echo "service start"
        # 执行Expect脚本
        output=$(expect $injectScript)
        break
    fi

    # 等待一段时间后继续循环（可根据需要调整等待时间）
    echo "waiting for service start"


    # 更新循环计数器
    i=$((i + 1))

done

# 读取文件内容，并去除末尾的 \r\n
file_content=$(sed 's/\r$//' "$licenseFile")
echo $file_content > $licenseFile

# 删除临时文件
rm -f $injectScript
docker restart artifactory

# TODO: 自动通过api来更新license