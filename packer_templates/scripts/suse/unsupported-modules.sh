#!/bin/sh

# Enable unsupported kernel modules, so virtualboxguest can install
echo 'allow_unsupported_modules 1' > /etc/modprobe.d/10-unsupported-modules.conf
