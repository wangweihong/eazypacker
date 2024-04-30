#!/bin/bash
set -ex

admin_name="admin"
admin_password="admin123"
user_name="user1"
user_password="user1"

# nginx proxy for filebrowser
# location /filebrowser {
#     # prevents 502 bad gateway error
#     proxy_buffers 8 32k;
#     proxy_buffer_size 64k;

#     client_max_body_size 75M;

#     # redirect all HTTP traffic to localhost:8088;
#     proxy_pass http://localhost:8080;
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header Host $http_host;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     #proxy_set_header X-NginX-Proxy true;

#     # enables WS support
#     proxy_http_version 1.1;
#     proxy_set_header Upgrade $http_upgrade;
#     proxy_set_header Connection "upgrade";

#     proxy_read_timeout 999999999;
# }
rm /var/lib/docker/volumes/filebrowser_data -rf || true
rm /var/lib/docker/volumes/filebrowser_config -rf || true

docker volume rm filebrowser_data || true
docker volume rm filebrowser_config || true

docker stop filebrowser-init || true

# create config
docker run -d --rm \
    --name filebrowser-init \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    hurlenko/filebrowser

sleep 3
docker stop filebrowser-init || true

docker run --rm \
    --name filebrowser-init \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    --entrypoint="/filebrowser" \
    hurlenko/filebrowser -d /config/filebrowser.db  users update admin --username $admin_name --password $admin_password

docker run --rm \
    --name filebrowser-init \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    --entrypoint="/filebrowser" \
    hurlenko/filebrowser -d /config/filebrowser.db users add $user_name $user_password

docker run --rm \
    --name filebrowser-init \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    --entrypoint="/filebrowser" \
    hurlenko/filebrowser -d /config/filebrowser.db users update $user_name --perm.delete=false

docker run --rm \
    --name filebrowser-init \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    --entrypoint="/filebrowser" \
    hurlenko/filebrowser -d /config/filebrowser.db users update $user_name --perm.create=false

docker run -d \
    --restart=always \
    --name filebrowser \
    --user $(id -u):$(id -g) \
    -p 8080:8080 \
    -v filebrowser_data:/data \
    -v filebrowser_config:/config \
    -e FB_BASEURL=/filebrowser \
    hurlenko/filebrowser
