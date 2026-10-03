#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends grub2-common
apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/*
