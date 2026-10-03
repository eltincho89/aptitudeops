#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  git zsh python3 python3-pip python3-venv pipx nodejs npm \
  docker.io docker-cli containerd \
  build-essential make jq ripgrep fd-find bat fzf tmux htop neovim openssh-client unzip
usermod -aG docker dev
chsh -s /usr/bin/zsh dev
systemctl enable docker || true
apt-get clean
rm -rf /var/lib/apt/lists/*
