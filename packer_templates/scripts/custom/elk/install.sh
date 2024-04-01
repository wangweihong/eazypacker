#!/bin/bash
set -e
set -x

ESVERSION="8.10.4"
RootDIR=/es
mkdir -p $RootDIR
chmod +777 $RootDIR


# 拷贝配置出来
if [ ! -e $RootDIR/config ];then 
    sudo -s docker run  -d --rm  --name esinit  docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION

    mkdir -p $RootDIR/config
    sudo -s docker cp esinit:/usr/share/elasticsearch/config $RootDIR/
    sudo -s docker stop esinit 

fi

mkdir -p $RootDIR/data
mkdir -p $RootDIR/log 
mkdir -p $RootDIR/plugin

chmod +777 $RootDIR/config 
chmod +777 $RootDIR/data
chmod +777 $RootDIR/log 
chmod +777 $RootDIR/plugin


docker network create elk --subnet=172.18.0.0/16 || true

sudo -s docker run --restart=always -d --name es01 \
    --net elk --ip 172.18.0.100 -p 9200:9200 -p 9300:9300  \
    --privileged \
    -v $RootDIR/data:/usr/share/elasticsearch/data \
    -v $RootDIR/log:/usr/share/elasticsearch/logs \
    -v $RootDIR/config:/usr/share/elasticsearch/config \
    -v $RootDIR/plugin:/usr/share/elasticsearch/plugins \
    -e "discovery.type=single-node" -m 2G \
    docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION


# curl -L  https://github.com/infinilabs/analysis-ik/releases/download/v$ESVERSION/elasticsearch-analysis-ik-$ESVERSION.zip -o $RootDIR/elasticsearch-analysis-ik-$ESVERSION.zip

# apt install -y zip 

# unzip $RootDIR/elasticsearch-analysis-ik-$ESVERSION.zip -d $RootDIR/plugin/elasticsearch-analysis-ik-$ESVERSION

# docker restart es01