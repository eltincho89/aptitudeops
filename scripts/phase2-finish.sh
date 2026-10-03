#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C

echo "== Instalando systemd-resolved =="
apt-get install -y systemd-resolved

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
