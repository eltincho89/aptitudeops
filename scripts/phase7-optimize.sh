#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
apt-get purge -y yelp gnome-user-docs gnome-core || true
apt-get install -y --no-install-recommends gnome-shell gdm3 nautilus gnome-control-center gnome-terminal gnome-text-editor gnome-session gnome-settings-daemon gnome-keyring gvfs-backends xdg-desktop-portal-gnome gnome-backgrounds
apt-get autoremove -y --purge
cat > /etc/dpkg/dpkg.cfg.d/01-nodoc <<'EOD'
path-exclude /usr/share/doc/*
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/info/*
path-exclude /usr/share/help/*
path-exclude /usr/share/locale/*
path-include /usr/share/locale/en*
path-include /usr/share/locale/locale.alias
EOD
find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' ! -name locale.alias -exec rm -rf {} +
rm -rf /usr/share/man/* /usr/share/info/* /usr/share/help/*
find /usr/share/doc -type f ! -name copyright -delete; find /usr/share/doc -type d -empty -delete
apt-get clean; rm -rf /var/lib/apt/lists/* /var/cache/debconf/*-old /var/lib/dpkg/*-old
