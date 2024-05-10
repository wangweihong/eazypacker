#!/bin/bash
set -e
set -x

ESVERSION="8.10.4"
ESNAME="es01"
ESNET="elk"
ES_ROOT_DIR=/elk/es
CA_PASSWORD=elastic
KIBANA_ROOT_DIR=/elk/kibana

mkdir -p $KIBANA_ROOT_DIR
chmod 777 $KIBANA_ROOT_DIR
# 拷贝配置出来
if [ ! -e $KIBANA_ROOT_DIR/config ]; then
    sudo -s docker run -d --rm --name kibanainit docker.elastic.co/kibana/kibana:$ESVERSION

    mkdir -p $KIBANA_ROOT_DIR/config
    chmod 777 $KIBANA_ROOT_DIR/config
    sudo -s docker cp kibanainit:/usr/share/kibana/config $ROOT_DIR/
    sudo -s docker stop kibanainit
fi


cp $ES_ROOT_DIR/pki/ca.crt $KIBANA_ROOT_DIR/config/
chmod 666 $KIBANA_ROOT_DIR/config/ca.crt


cat <<EOF >>$KIBANA_ROOT_DIR/config/kibana.yml
elasticsearch.ssl.certificateAuthorities: /usr/share/kibana/config/ca.crt
elasticsearch.hosts: https://$ESNAME:9200
EOF

sudo -s docker run -d \
    --restart=always \
    --name kibana \
    -e ELASTICSEARCH_HOSTS=http://$ESNAME:9200 \
    --network=$ESNET \
    -p 5601:5601 \
    -v $KIBANA_ROOT_DIR/config:/usr/share/kibana/config \
    docker.elastic.co/kibana/kibana:$ESVERSION
