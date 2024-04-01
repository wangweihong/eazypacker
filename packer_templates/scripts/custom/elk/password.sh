#!/bin/bash
set -e
set -x

autoResetPasswordScript="/tmp/auto-expect-password.exp"

cat  << 'EOF' > $autoResetPasswordScript
#!/usr/bin/expect -f

set timeout 20

spawn docker exec -it es01 elasticsearch-reset-password -u elastic -i
expect "Please confirm that you would like to continue \[y/N\]"
send "y\r"

expect "Enter password for \[elastic\]:"
send "elastic\r"

expect "Re-enter password for \[elastic\]:"
send "elastic\r"

expect "Password for the \[elastic\] user successfully reset."

EOF

chmod +x "$autoResetPasswordScript"
iterations=10

i=1
while [ $i -le $iterations ]; do
    # 等待一段时间后继续循环（可根据需要调整等待时间）
    echo "waiting for service start"

    sleep 10
    # 代理可能会影响到curl -s -o的结果。如果返回结果为503, 则有可能是由于代理导致的。
    # ret=`curl --proxy "" -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9200;`
    curl_output=$(curl --proxy "" -s http://127.0.0.1:9200 || true)
    if echo "$curl_output" | grep -q "401"; then
        echo "service start"
        # 执行Expect脚本
        output=$(expect $autoResetPasswordScript)
        break
    fi

    # 更新循环计数器
    i=$((i + 1))

done

if [ $i -gt $iterations ] ; then
    echo "try $iterations times waiting for service start, but failed"
    exit 1
fi

docker restart es01
rm $autoResetPasswordScript