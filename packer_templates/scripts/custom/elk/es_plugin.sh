#!/bin/bash
set -e
set -x


ESVERSION="8.10.4"
ESNAME="es01"
ROOT_DIR=/elk/es
CA_PASSWORD=elastic

if ! [ -e $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip ]; then
    curl -L https://github.com/infinilabs/analysis-ik/releases/download/v$ESVERSION/elasticsearch-analysis-ik-$ESVERSION.zip -o $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip
    if ! [ -x "$(command -v zip)" ]; then
        apt install -y zip
    fi
fi
unzip $ROOT_DIR/elasticsearch-analysis-ik-$ESVERSION.zip -d $ROOT_DIR/plugin/elasticsearch-analysis-ik-$ESVERSION

docker restart $ESNAME