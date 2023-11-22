#!/bin/bash
set -e
set -x

curl -fsSL https://get.pulumi.com | sh -s -- --version ${PULUMI_VERSION}