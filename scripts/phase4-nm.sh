#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends network-manager network-manager-gnome
systemctl disable systemd-networkd systemd-networkd-wait-online || true
systemctl enable NetworkManager
mkdir -p /etc/systemd/network-disabled
mv /etc/systemd/network/*.network /etc/systemd/network-disabled/ 2>/dev/null || true
apt-get clean
rm -rf /var/lib/apt/lists/*
