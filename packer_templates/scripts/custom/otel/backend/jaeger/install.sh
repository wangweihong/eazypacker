#!/bin/bash
set -ex

JAEGER_VERSION=${JAEGER_VERSION:-1.59}

# Port	Protocol	Component	Function
# 6831	UDP	        agent	accept jaeger.thrift over Thrift-compact protocol (used by most SDKs)
# 6832	UDP	        agent	accept jaeger.thrift over Thrift-binary protocol (used by Node.js SDK)
# 5775	UDP	        agent	(deprecated) accept zipkin.thrift over compact Thrift protocol (used by legacy clients only)
# 5778	HTTP	    agent	serve configs (sampling, etc.)
# 16686	HTTP	    query	serve frontend
# 4317	HTTP	    collector	accept OpenTelemetry Protocol (OTLP) over gRPC
# 4318	HTTP	    collector	accept OpenTelemetry Protocol (OTLP) over HTTP
# 14268	HTTP	    collector	accept jaeger.thrift directly from clients
# 14250	HTTP	    collector	accept model.proto
# 9411	HTTP	    collector	Zipkin compatible endpoint (optional)

# 注意:
# 必须设置COLLECTOR_OTLP_GRPC_HOST_PORT, OTEL客户端才能正常发送遥测数据到jaeger
# 且客户端访问时要指定真实主机IP, 不能是127.0.0.1
# 见https://github.com/jaegertracing/jaeger/issues/5202
docker run -d --name jaeger \
    -e COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
    -e COLLECTOR_OTLP_GRPC_HOST_PORT=:4317 \
    -e LOG_LEVEL=debug \
    -p 6831:6831/udp \
    -p 6832:6832/udp \
    -p 5778:5778 \
    -p 16686:16686 \
    -p 4317:4317 \
    -p 4318:4318 \
    -p 14250:14250 \
    -p 14268:14268 \
    -p 14269:14269 \
    -p 9411:9411 \
    jaegertracing/all-in-one:${JAEGER_VERSION}

