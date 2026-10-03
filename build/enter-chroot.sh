#!/bin/bash
set -e
CHROOT_DIR="$(dirname "$(readlink -f "$0")")/chroot"
mount --bind /dev "$CHROOT_DIR/dev"
mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
mount -t proc proc "$CHROOT_DIR/proc"
mount -t sysfs sysfs "$CHROOT_DIR/sys"
mount -t tmpfs tmpfs "$CHROOT_DIR/tmp"
cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
chroot "$CHROOT_DIR" /bin/bash
