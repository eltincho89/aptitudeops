#!/bin/bash
set -ex
dconf update
systemctl disable bluetooth.service NetworkManager-wait-online.service apt-daily.timer apt-daily-upgrade.timer dpkg-db-backup.timer fstrim.timer systemd-pstore.service || true
systemctl disable docker.service containerd.service || true   # docker.socket sigue enabled: arranca bajo demanda
systemctl mask ModemManager.service cups.service avahi-daemon.service 2>/dev/null || true
