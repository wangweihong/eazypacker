#!/bin/sh -eux

# motd.sh用于在用户登陆时打印欢迎信息
## TODO: 加入版本信息?
welcome='
This system is built by the EazyPacker project for learning'

if [ -d /etc/update-motd.d ]; then
    MOTD_CONFIG='/etc/update-motd.d/99-eazypacker'

    cat >> "$MOTD_CONFIG" <<DATA
#!/bin/sh

cat <<'EOF'
$welcome
EOF
DATA

    chmod 0755 "$MOTD_CONFIG"
else
    echo "$welcome" >> /etc/motd
fi
