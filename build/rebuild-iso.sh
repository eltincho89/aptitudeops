#!/bin/bash
# Regenera squashfs + ISO de AptitudeOPS (ejecutar con sudo desde build/)
# Genera AptitudeOPS.iso y una copia versionada AptitudeOPS-<version>-<fecha>.iso + .sha256
set -e
cd "$(dirname "$0")"
VERSION=$(sed -n 's/^IMAGE_VERSION=//p' chroot/etc/os-release)
BUILD=$(sed -n 's/^BUILD_ID=//p' chroot/etc/os-release)
chown root:root chroot && chmod 755 chroot   # el dir raiz del chroot NO debe ser de un usuario normal (si no, / queda con ese uid en el sistema instalado)
cp chroot/boot/vmlinuz-* iso/live/vmlinuz
cp chroot/boot/initrd.img-* iso/live/initrd.img
rm -f iso/live/filesystem.squashfs AptitudeOPS.iso
mksquashfs chroot iso/live/filesystem.squashfs -comp xz -Xbcj x86 -b 1M -noappend -wildcards -e 'proc/*' 'sys/*' 'dev/*' 'run/*' 'tmp/*'
grub-mkrescue -o AptitudeOPS.iso iso -volid APTITUDEOPS
OUT="AptitudeOPS-${VERSION}-${BUILD}.iso"
rm -f AptitudeOPS-*.iso AptitudeOPS-*.iso.sha256
cp AptitudeOPS.iso "$OUT"
sha256sum "$OUT" > "$OUT.sha256"
ls -lh AptitudeOPS.iso "$OUT"; cat "$OUT.sha256"
