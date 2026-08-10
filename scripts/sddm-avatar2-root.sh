#!/bin/bash
# Avatar SDDM = ảnh thật từ AccountsService (ảnh mà lock screen đang hiển thị)
# + đổi chấm mật khẩu SilentSDDM sang chấm nhỏ "•"
set -euo pipefail
SRC=/var/lib/AccountsService/icons/hieubt
[ -r "$SRC" ] || { echo "Không đọc được $SRC" >&2; exit 1; }
cp -f "$SRC" /usr/share/sddm/faces/hieubt.face.icon
chmod 644 /usr/share/sddm/faces/hieubt.face.icon
# đồng bộ luôn ~/.face để mọi nơi dùng cùng một ảnh
cp -f "$SRC" /home/hieubt/.face
chown hieubt:hieubt /home/hieubt/.face
# chấm mật khẩu nhỏ lại
sed -i 's/masked-character = "●"/masked-character = "•"/' /usr/share/sddm/themes/silent/configs/catppuccin-mocha.conf
grep -n 'masked-character' /usr/share/sddm/themes/silent/configs/catppuccin-mocha.conf
echo OK
