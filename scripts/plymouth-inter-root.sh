#!/bin/bash
# Hoàn tất 2 bước còn dở: Plymouth Catppuccin (qua update-alternatives) + fonts-inter
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Cần root" >&2; exit 1; }

echo "=== Plymouth ==="
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/catppuccin-mocha/catppuccin-mocha.plymouth 200
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/catppuccin-mocha/catppuccin-mocha.plymouth
echo "Theme: $(readlink -f /etc/alternatives/default.plymouth)"
update-initramfs -u 2>&1 | tail -2

echo "=== fonts-inter ==="
export DEBIAN_FRONTEND=noninteractive
apt-get install -y fonts-inter 2>&1 | tail -1

echo "HOÀN TÁC: update-alternatives --set default.plymouth /usr/share/plymouth/themes/debian-logo/debian-logo.plymouth && update-initramfs -u"
