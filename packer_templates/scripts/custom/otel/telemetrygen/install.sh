#!/bin/bash
set -ex

#  模拟生成遥测数据
#  注意如果otlp-endpoint指向jaeger-all-in-one, 需要填写真实主机IP
docker run --rm \
    ghcr.io/open-telemetry/opentelemetry-collector-contrib/telemetrygen:latest \
    traces \
    --otlp-insecure \
    --otlp-endpoint=127.0.0.1:4317 \
    --duration=30s \
    --workers=4 \
    --rate=4      