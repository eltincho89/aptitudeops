#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get update
apt-get install -y --no-install-recommends \
  gnome-core gdm3 gnome-terminal xdg-user-dirs xdg-utils \
  pipewire pipewire-pulse wireplumber fonts-noto-core fonts-dejavu-core \
  firefox-esr
systemctl enable gdm3
systemctl set-default graphical.target
apt-get clean
rm -rf /var/lib/apt/lists/*
