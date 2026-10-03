#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends iproute2 iputils-ping
apt-get clean; rm -rf /var/lib/apt/lists/*
