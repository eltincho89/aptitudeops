#!/bin/bash
CHROOT_DIR="$(dirname "$(readlink -f "$0")")/chroot"
umount -lf "$CHROOT_DIR/dev/pts" 2>/dev/null
umount -lf "$CHROOT_DIR/dev" 2>/dev/null
umount -lf "$CHROOT_DIR/proc" 2>/dev/null
umount -lf "$CHROOT_DIR/sys" 2>/dev/null
umount -lf "$CHROOT_DIR/tmp" 2>/dev/null
echo "Chroot desmontado."
