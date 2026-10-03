#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends live-boot live-config live-config-systemd
update-initramfs -u -k all
apt-get clean
rm -rf /var/lib/apt/lists/*
