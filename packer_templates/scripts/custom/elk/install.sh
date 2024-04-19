#!/bin/bash
set -e
set -x

ESVERSION="8.10.4"
ESNAME="es01"
ESNET="elk"
SUBNET="172.22.0.0/16"
ELK_IP="172.22.0.100"
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

# harbor默认使用172.18.0.0/16的网段, 避免可能的冲突
docker network create $ESNET --subnet=$SUBNET || true

# -e "discovery.type=single-node" -m 1G 设置java的堆内存
# 如果服务器内存不足, 会导致elasticsearch无法启动： ERROR: Elasticsearch exited unexpectedly, with exit code 137
sudo -s docker run --restart=always -d --name $ESNAME \
    --net $ESNET --ip $ELK_IP -p 9200:9200 -p 9300:9300  \
    --privileged \
    -v $RootDIR/data:/usr/share/elasticsearch/data \
    -v $RootDIR/log:/usr/share/elasticsearch/logs \
    -v $RootDIR/config:/usr/share/elasticsearch/config \
    -v $RootDIR/plugin:/usr/share/elasticsearch/plugins \
    -e "discovery.type=single-node" -m 1G \
    docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION

if ! [ -e $RootDIR/elasticsearch-analysis-ik-$ESVERSION.zip ];then
  curl -L  https://github.com/infinilabs/analysis-ik/releases/download/v$ESVERSION/elasticsearch-analysis-ik-$ESVERSION.zip -o $RootDIR/elasticsearch-analysis-ik-$ESVERSION.zip
  if ! [ -x "$(command -v zip)" ]; then
      apt install -y zip
  fi
fi
unzip $RootDIR/elasticsearch-analysis-ik-$ESVERSION.zip -d $RootDIR/plugin/elasticsearch-analysis-ik-$ESVERSION

docker restart $ESNAME