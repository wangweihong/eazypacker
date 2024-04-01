#!/usr/bin/env bash
set -e
set -x


RootDIR=/es
ESNAME="es01"

docker run -d --restart=always --name es-head -p 9100:9100    docker.io/mobz/elasticsearch-head:5

echo "http.cors.enabled: true"   >> $RootDIR/config/elasticsearch.yml
echo "http.cors.allow-origin: \"*\"" >> $RootDIR/config/elasticsearch.yml

docker restart $ESNAME

# access
# http://<ip>:9100/?auth_user=elastic&auth_password=elastic