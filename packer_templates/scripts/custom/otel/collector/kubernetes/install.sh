#!/bin/bash
set -ex

OTEL_VERSION=${OTEL_VERSION:-v0.103.1}

kubectl apply -f https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector/${OTEL_VERSION}/examples/k8s/otel-config.yaml
