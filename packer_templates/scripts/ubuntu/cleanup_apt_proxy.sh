#!/bin/bash
set -e
set -x


rm /etc/apt/apt.conf

if [ -e /etc/apt/apt.conf.bk ]; then
    mv /etc/apt/apt.conf.bk  /etc/apt/apt.conf
fi