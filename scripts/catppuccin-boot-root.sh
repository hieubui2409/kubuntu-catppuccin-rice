#!/bin/bash
# =============================================================================
#  Catppuccin đợt 2 — phần hệ thống:
#   1. Cursor Catppuccin Mauve cho SDDM (copy vào /usr/share/icons + đặt trong kde_settings)
#   2. GRUB theme Catppuccin Mocha (thay darkmatter, backup dòng cấu hình cũ)
#   3. Plymouth Catppuccin Mocha (rebuild initramfs)
#   4. apt install fonts-inter
#  Backup: /root/catppuccin-boot-backup-<ts>
# =============================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Cần root" >&2; exit 1; }
DL=/tmp/claude-1000/-home-hieubt-Documents-cleanup-pc/3eb86d77-dfc4-4584-abe3-169e5cf1cfc5/scratchpad/catppuccin
TS=$(date +%Y%m%d-%H%M%S); BK="/root/catppuccin-boot-backup-$TS"
mkdir -p "$BK"
cp -a /etc/default/grub "$BK/grub.default"
cp -a /etc/sddm.conf.d/kde_settings.conf "$BK/"
plymouth-set-default-theme > "$BK/plymouth-theme.old" 2>/dev/null || true
echo "Backup: $BK"

echo "=== [1/4] Cursor SDDM ==="
cp -r /home/hieubt/.local/share/icons/catppuccin-mocha-mauve-cursors /usr/share/icons/
chmod -R a+rX /usr/share/icons/catppuccin-mocha-mauve-cursors
sed -i 's/^CursorTheme=.*/CursorTheme=catppuccin-mocha-mauve-cursors/' /etc/sddm.conf.d/kde_settings.conf
grep CursorTheme /etc/sddm.conf.d/kde_settings.conf

echo "=== [2/4] GRUB theme Catppuccin Mocha ==="
mkdir -p /usr/share/grub/themes
cp -r "$DL/cp-grub/src/catppuccin-mocha-grub-theme" /usr/share/grub/themes/
sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"|' /etc/default/grub
grep GRUB_THEME /etc/default/grub
update-grub 2>&1 | tail -3

echo "=== [3/4] Plymouth Catppuccin Mocha ==="
cp -r "$DL/cp-plymouth/themes/catppuccin-mocha" /usr/share/plymouth/themes/
plymouth-set-default-theme -R catppuccin-mocha
echo "Plymouth mới: $(plymouth-set-default-theme)"

echo "=== [4/4] fonts-inter ==="
export DEBIAN_FRONTEND=noninteractive
apt-get install -y fonts-inter 2>&1 | tail -1
fc-list | grep -ci inter || true

cat <<EOF

XONG. HOÀN TÁC
  cp -a $BK/grub.default /etc/default/grub && update-grub
  cp -a $BK/kde_settings.conf /etc/sddm.conf.d/
  plymouth-set-default-theme -R \$(cat $BK/plymouth-theme.old)
  rm -rf /usr/share/grub/themes/catppuccin-mocha-grub-theme /usr/share/plymouth/themes/catppuccin-mocha /usr/share/icons/catppuccin-mocha-mauve-cursors
EOF
