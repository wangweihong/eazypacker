#!/usr/bin/env bash
set -ex

# 注意: docker-compose使用golang重写了v2版本
#DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-1.24.1}
DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-v2.28.1}

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# TODO: Install Docker buildx