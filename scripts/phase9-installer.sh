#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends calamares calamares-settings-debian plymouth plymouth-themes \
  grub-efi-amd64-bin grub-pc-bin efibootmgr parted dosfstools e2fsprogs rsync squashfs-tools os-prober cryptsetup
# quitar toolchain C (make se conserva)
apt-mark manual make
apt-get purge -y build-essential g++ gcc || true
apt-get autoremove -y --purge
apt-get clean; rm -rf /var/lib/apt/lists/*
