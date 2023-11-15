#!/bin/bash

set -o errexit
set -o nounset

export PATH=/usr/local/bin:$PATH
SCRIPT_ROOT="$(cd "$(dirname "$0")" && pwd)"


curl -fsSL https://goss.rocks/install | GOSS_VER=v0.3.16 GOSS_DST=/usr/bin sh
#goss --vars vars.yaml -g goss.yaml validate --retry-timeout=10s