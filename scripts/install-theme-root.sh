#!/bin/bash
# =============================================================================
#  Cài phần hệ thống của bộ theme Catppuccin:
#   1. Plugin KWin bo góc (kwin4_effect_shapecorners) đã build sẵn
#   2. Theme SilentSDDM (đã test OK bằng sddm-greeter-qt6 --test-mode)
#   3. Font RedHat cho SDDM + đặt theme silent làm mặc định
#  Backup: /root/sddm-silent-backup-<ts>
# =============================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Cần root" >&2; exit 1; }

DL=/tmp/claude-1000/-home-hieubt-Documents-cleanup-pc/3eb86d77-dfc4-4584-abe3-169e5cf1cfc5/scratchpad/catppuccin
TS=$(date +%Y%m%d-%H%M%S); BK="/root/sddm-silent-backup-$TS"
mkdir -p "$BK"; cp -a /etc/sddm.conf.d "$BK/" 2>/dev/null || true
echo "Backup: $BK"

echo "=== [1/3] Plugin KWin bo góc ==="
cd "$DL/KDE-Rounded-Corners/build"
ninja install 2>&1 | grep -E 'Installing|Up-to-date' | head -8

echo "=== [2/3] SilentSDDM ==="
mkdir -p /usr/share/sddm/themes/silent
cp -rf "$DL/SilentSDDM/." /usr/share/sddm/themes/silent/
rm -rf /usr/share/sddm/themes/silent/.git
cp -r /usr/share/sddm/themes/silent/fonts/redhat /usr/share/fonts/ 2>/dev/null || true
cp -r /usr/share/sddm/themes/silent/fonts/redhat-vf /usr/share/fonts/ 2>/dev/null || true
fc-cache -f >/dev/null 2>&1 || true

echo "=== [3/3] Đặt theme silent làm mặc định ==="
CONF=/etc/sddm.conf.d/kde_settings.conf
if grep -q '^Current=' "$CONF" 2>/dev/null; then
  sed -i 's/^Current=.*/Current=silent/' "$CONF"
else
  printf '\n[Theme]\nCurrent=silent\n' >> "$CONF"
fi
# bàn phím ảo cho màn đăng nhập (SilentSDDM khuyến nghị)
if ! grep -q 'InputMethod=qtvirtualkeyboard' "$CONF"; then
  if grep -q '^\[General\]' "$CONF"; then
    sed -i '/^\[General\]/a InputMethod=qtvirtualkeyboard' "$CONF"
  else
    printf '\n[General]\nInputMethod=qtvirtualkeyboard\n' >> "$CONF"
  fi
fi
echo "--- $CONF ---"; cat "$CONF"

cat <<EOF

XONG.
HOÀN TÁC
  cp -a $BK/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/
  rm -rf /usr/share/sddm/themes/silent /usr/share/fonts/redhat /usr/share/fonts/redhat-vf
  rm -f /usr/lib/x86_64-linux-gnu/qt6/plugins/kwin/effects/plugins/kwin4_effect_shapecorners.so \
        /usr/lib/x86_64-linux-gnu/qt6/plugins/kwin/effects/configs/kwin_shapecorners_config.so
EOF
