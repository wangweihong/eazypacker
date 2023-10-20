#!/bin/sh -eux

if [ -e /etc/apt/sources.list.bak ];then
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
fi