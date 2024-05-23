#!/bin/bash
set -e
set -x

PULUMI_VERSION=${PULUMI_VERSION:-"x86_64"}

curl -fsSL https://get.pulumi.com | sh -s -- --version ${PULUMI_VERSION}