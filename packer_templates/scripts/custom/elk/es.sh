#!/bin/bash
set -e
set -x


ESVERSION="8.10.4"
ESNAME="es01"
ESNET="elk"
SUBNET="172.22.0.0/16"
ELK_IP="172.22.0.100"
ROOT_DIR=/elk/es


mkdir -p $ROOT_DIR
chmod +666 $ROOT_DIR

# 拷贝配置出来
if [ ! -e $ROOT_DIR/config ]; then
    sudo -s docker run -d --rm --name esinit docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION
    mkdir -p $ROOT_DIR/config
    sudo -s docker cp esinit:/usr/share/elasticsearch/config $ROOT_DIR/
    sudo -s docker stop esinit
fi

mkdir -p $ROOT_DIR/data
mkdir -p $ROOT_DIR/log
mkdir -p $ROOT_DIR/plugin

chmod -R 666 $ROOT_DIR/config
chmod 666 $ROOT_DIR/data
chmod 666 $ROOT_DIR/log
chmod 666 $ROOT_DIR/plugin

# harbor默认使用172.18.0.0/16的网段, 避免可能的冲突
docker network create $ESNET --subnet=$SUBNET || true

# -e "discovery.type=single-node" -m 1G 设置java的堆内存
# 如果服务器内存不足, 会导致elasticsearch无法启动： ERROR: Elasticsearch exited unexpectedly, with exit code 137
sudo -s docker run --restart=always -d --name $ESNAME \
    --net $ESNET --ip $ELK_IP -p 9200:9200 -p 9300:9300 \
    --privileged \
    -v $ROOT_DIR/data:/usr/share/elasticsearch/data \
    -v $ROOT_DIR/log:/usr/share/elasticsearch/logs \
    -v $ROOT_DIR/config:/usr/share/elasticsearch/config \
    -v $ROOT_DIR/plugin:/usr/share/elasticsearch/plugins \
    -e "discovery.type=single-node" -m 1G \
    docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION


