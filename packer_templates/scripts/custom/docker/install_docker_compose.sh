#!/usr/bin/env bash
# script for config apt/wget/curl/docker proxy
set -ex

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# TODO: Install Docker buildx