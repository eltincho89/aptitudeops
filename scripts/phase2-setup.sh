#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C

echo "== apt update =="
apt-get update

echo "== Locale =="
apt-get install -y locales
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale

echo "== Timezone =="
apt-get install -y tzdata
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
echo "America/Argentina/Buenos_Aires" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo "== Hostname =="
echo "devbox" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
127.0.1.1   devbox
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

echo "== Paquetes esenciales + kernel =="
apt-get install -y --no-install-recommends \
  systemd-sysv udev kmod sudo \
  less nano curl wget ca-certificates gnupg2 \
  console-setup keyboard-configuration \
  linux-image-amd64

echo "== Red (systemd-networkd + resolved) =="
systemctl enable systemd-networkd
systemctl enable systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
mkdir -p /etc/systemd/network
cat > /etc/systemd/network/10-dhcp.network <<EOF
[Match]
Name=en* eth*

[Network]
DHCP=yes
EOF

echo "== Usuario y contrasenas (TEMPORALES) =="
useradd -m -s /bin/bash -G sudo dev
echo "dev:${DEV_PASSWORD:?definir DEV_PASSWORD}" | chpasswd
echo "root:${DEV_PASSWORD:?definir DEV_PASSWORD}" | chpasswd

echo "== Fase 2 completada =="
