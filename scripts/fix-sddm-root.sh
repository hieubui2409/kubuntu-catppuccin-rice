#!/bin/bash
# =============================================================================
#  SỬA MÀN HÌNH ĐĂNG NHẬP SDDM SAU NÂNG CẤP 26.04
#  Chạy:  sudo /home/hieubt/Documents/cleanup-pc/fix-sddm-root.sh
#
#  BA LỖI ĐƯỢC SỬA
#  1. Theme "Wings-Light-SDDM" viết cho Qt5 (import QtQuick 2.8) nhưng greeter
#     giờ là sddm-greeter-qt6 -> Main.qml:58/61 lỗi kiểu -> giao diện vỡ.
#     Trên máy chỉ có 4 theme Qt6 thật: breeze, kubuntu, kubuntu-light,
#     ubuntu-theme. Mọi theme đẹp khác (sugar-candy, Sweet-Ambar-Blue, Nordic,
#     We10XOS, plasma-chili...) đều là Qt5 -> sẽ vỡ y hệt.
#  2. Greeter chạy Wayland báo:
#        kwin_wayland_drm: atomic commit failed: Permission denied
#        kwin_core: Failed to open /dev/dri/renderD128 (No such device)
#     Nguyên nhân: user `sddm` chỉ thuộc nhóm `sddm`, KHÔNG thuộc `video`
#     và `render`, trong khi /dev/dri/card* thuộc nhóm video và renderD12*
#     thuộc nhóm render (mode crw-rw----). Máy có GPU lai Intel UHD 770 +
#     NVIDIA RTX 3060 nên greeter cần cả hai.
#  3. CursorTheme=Layan-white-cursors không còn trên máy (chỉ còn
#     breeze_cursors) -> con trỏ về mặc định xấu.
# =============================================================================
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Cần root:  sudo $0" >&2; exit 1; }

TS=$(date +%Y%m%d-%H%M%S)
BK="/root/sddm-backup-$TS"
mkdir -p "$BK"
cp -a /etc/sddm.conf.d "$BK/"
echo "Backup: $BK"

WALL="/home/hieubt/Documents/images/IMG_20230128_013920_990.jpg"

# --- 1. Quyền GPU cho greeter -------------------------------------------------
echo
echo "=== [1/4] Thêm user sddm vào nhóm video + render ==="
usermod -aG video,render sddm
id sddm

# --- 2. Theme ------------------------------------------------------------------
echo
echo "=== [2/4] Chuyển theme sang breeze (Qt6) + cursor có thật ==="
cat > /etc/sddm.conf.d/kde_settings.conf <<'EOF'
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=
RebootCommand=

[Theme]
Current=breeze
CursorTheme=breeze_cursors
CursorSize=24
Font=Noto Sans,10,-1,5,50,0,0,0,0,0

[Users]
MaximumUid=60000
MinimumUid=1000
EOF
echo "    kde_settings.conf -> Current=breeze"

# 20-kubuntu.conf cũng đặt Current=kubuntu; kde_settings.conf đứng sau theo thứ
# tự alphabet nên thắng. Không cần sửa file của gói.

# --- 3. Ảnh nền ----------------------------------------------------------------
echo
echo "=== [3/4] Đặt ảnh nền cho theme breeze ==="
if [ -f "$WALL" ]; then
    install -m 0644 "$WALL" /usr/share/sddm/themes/breeze/wallpaper.jpg
    cat > /usr/share/sddm/themes/breeze/theme.conf.user <<'EOF'
[General]
type=image
background=wallpaper.jpg
EOF
    echo "    đã dùng $WALL"
else
    echo "    KHÔNG tìm thấy $WALL — giữ nền mặc định"
fi

# --- 4. Kiểm tra ---------------------------------------------------------------
echo
echo "=== [4/4] Kiểm tra ==="
echo "--- Cấu hình SDDM hiệu lực (Theme) ---"
grep -h -A6 "^\[Theme\]" /etc/sddm.conf.d/*.conf | grep -E "Current|Cursor"
echo "--- Nhóm của sddm ---"; id sddm

cat <<EOF

=============================================================================
XONG. Backup: $BK

ÁP DỤNG: thay đổi nhóm video/render chỉ có hiệu lực khi SDDM khởi động lại.
  - An toàn nhất: reboot.
  - Hoặc (SẼ ĐÓNG PHIÊN ĐỒ HOẠ ĐANG CHẠY):  systemctl restart sddm

NẾU SAU KHI REBOOT GREETER VẪN LỖI DRM, ép greeter về X11:
  printf '[General]\nDisplayServer=x11\n' | sudo tee /etc/sddm.conf.d/99-x11.conf

HOÀN TÁC: cp -a $BK/sddm.conf.d/. /etc/sddm.conf.d/
=============================================================================
EOF
