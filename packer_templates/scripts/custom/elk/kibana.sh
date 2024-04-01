#!/bin/bash
set -e
set -x

ESVERSION="8.10.4"
ESNAME="es01"
ESNET="elk"

sudo -s docker run -d \
--restart=always \
--name kibana \
-e ELASTICSEARCH_HOSTS=http://$ESNAME:9200 \
--network=$ESNET \
-p 5601:5601  \
docker.elastic.co/kibana/kibana:$ESVERSION