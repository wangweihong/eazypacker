#!/bin/bash
set -e
set -x

ESVERSION="8.10.4"
ESNAME="es01"
ESNET="elk"
SUBNET="172.22.0.0/16"
ELK_IP="172.22.0.100"
ROOT_DIR=/es
CA_PASSWORD=elastic

mkdir -p $ROOT_DIR
chmod +777 $ROOT_DIR

# 拷贝配置出来
if [ ! -e $ROOT_DIR/config ]; then
    sudo -s docker run -d --rm --name esinit docker.elastic.co/elasticsearch/elasticsearch:$ESVERSION

    # sudo -s docker exec esinit elasticsearch-certutil ca --out /usr/share/elasticsearch/config/elastic-stack-ca.p12 --pass $CA_PASSWORD --days 3650
    # # generate certificates
    # sudo -s docker exec esinit elasticsearch-certutil cert \
    #         --ca /usr/share/elasticsearch/config/elastic-stack-ca.p12 --ca-pass $CA_PASSWORD \
    #         --out /usr/share/elasticsearch/config/elastic-certificates.p12 --pass elastic

    mkdir -p $ROOT_DIR/config
    sudo -s docker cp esinit:/usr/share/elasticsearch/config $ROOT_DIR/

    # chmod 666 $ROOT_DIR/config/elastic-stack-ca.p12
    # chmod 666 $ROOT_DIR/config/elastic-certificates.p12

    # mkdir -p $ROOT_DIR/pki
    # sudo -s docker exec esinit mkdir -p /usr/share/elasticsearch/pki
    # generate ca

    sudo -s docker stop esinit
fi

mkdir -p $ROOT_DIR/data
mkdir -p $ROOT_DIR/log
mkdir -p $ROOT_DIR/plugin

chmod +777 $ROOT_DIR/config
chmod +777 $ROOT_DIR/data
chmod +777 $ROOT_DIR/log
chmod +777 $ROOT_DIR/plugin

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

cat <<EOF >>$ROOT_DIR/config/elasticsearch.yml
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.client_authentication: required
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
EOF

if [ "${ES_TLS+isset}" = "isset" ] && [ "${ES_TLS}" = "true" ]; then
    # https://www.elastic.co/guide/en/elasticsearch/reference/8.13/security-basic-setup.html#encrypt-internode-communication
    echo "config basid security for elasticsearch..."
    sudo -s docker exec $ESNAME elasticsearch-certutil ca --out /usr/share/elasticsearch/config/elastic-stack-ca.p12 --pass $CA_PASSWORD --days 3650
    # generate certificates
    sudo -s docker exec $ESNAME elasticsearch-certutil cert \
        --ca /usr/share/elasticsearch/config/elastic-stack-ca.p12 --ca-pass $CA_PASSWORD \
        --out /usr/share/elasticsearch/config/elastic-certificates.p12 --pass $CA_PASSWORD

    # 证书密码到keystore
    # 不能直接通过配置文件来设置。
    echo $CA_PASSWORD | sudo -s docker exec -i es01 elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password -s
    echo $CA_PASSWORD | sudo -s docker exec -i es01 elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password -s

    chmod 666 $ROOT_DIR/config/elastic-stack-ca.p12
    chmod 666 $ROOT_DIR/config/elastic-certificates.p12
fi

if ! [ -e $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip ]; then
    curl -L https://github.com/infinilabs/analysis-ik/releases/download/v$ESVERSION/elasticsearch-analysis-ik-$ESVERSION.zip -o $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip
    if ! [ -x "$(command -v zip)" ]; then
        apt install -y zip
    fi
fi
unzip $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip -d $ROOT_DIR/plugin/elasticsearch-analysis-ik-$ESVERSION

docker restart $ESNAME
