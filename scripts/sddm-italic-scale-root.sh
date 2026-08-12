#!/bin/bash
# =============================================================================
#  SỬA 2 LỖI HIỂN THỊ CỦA SDDM (theme SilentSDDM)
#  Chạy:  sudo /home/hieubt/Documents/cleanup-pc/sddm-italic-scale-root.sh
#
#  LỖI 1 — chữ "Password" bị in nghiêng
#     Hardcode trong theme, KHÔNG có tuỳ chọn config nào:
#         components/Input.qml:111   font.italic: true
#     Nó nằm trên phần placeholder (chỉ hiện khi ô mật khẩu còn trống).
#     Đây là chỗ duy nhất có `italic` trong theme (trừ VirtualKeyboard).
#
#  LỖI 2 — mọi thứ to quá trên màn 2K (DP-4), trong khi lock screen thì cân
#     components/Config.qml:11 nói rõ tuỳ chọn `scale` của theme là
#     "applied AFTER Qt's automatic per-display high-DPI scale" — tức theme
#     ăn theo scale mà compositor cấp, nó không tự tính.
#
#     Lock screen chạy TRONG phiên Plasma  -> dùng scale bạn đặt: DP-4 = 1.25
#     SDDM chạy kwin_wayland RIÊNG (user `sddm`, home /var/lib/sddm) và
#     instance đó KHÔNG có kwinoutputconfig.json -> nó tự đoán scale từ EDID.
#     DP-4 = 2560x1440 trên tấm 526x296mm (~23.8") = 124 DPI; 124/96 ~ 1.29,
#     tuỳ cách KWin làm tròn sẽ ra 1.25 hoặc 1.5. Ra 1.5 thì to hơn đúng 20%.
#
#     Cách sửa: đưa cho kwin của SDDM đúng file cấu hình màn hình của phiên
#     Plasma -> hai bên render giống hệt nhau (HDMI-A-5 scale 1, DP-4 scale 1.25).
#
#  LƯU Ý: sửa Input.qml nằm trong /usr/share nên sẽ BỊ GHI ĐÈ nếu cài lại
#  hoặc cập nhật theme SilentSDDM. Chạy lại script này là xong (idempotent).
# =============================================================================
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Cần root:  sudo $0" >&2; exit 1; }

USER_HOME="/home/hieubt"
THEME="/usr/share/sddm/themes/silent"
INPUT_QML="$THEME/components/Input.qml"
SRC_OUTCFG="$USER_HOME/.config/kwinoutputconfig.json"
SDDM_CFG="/var/lib/sddm/.config"

TS=$(date +%Y%m%d-%H%M%S)
BK="/root/sddm-italic-scale-backup-$TS"
mkdir -p "$BK"
echo "Backup: $BK"

# --- 1. Bỏ in nghiêng cho placeholder "Password" ------------------------------
echo
echo "=== [1/2] Bỏ italic cho placeholder mật khẩu ==="
if [ ! -f "$INPUT_QML" ]; then
    echo "  !! Không tìm thấy $INPUT_QML — bỏ qua"
elif grep -q "font\.italic: true" "$INPUT_QML"; then
    cp -a "$INPUT_QML" "$BK/Input.qml"
    sed -i 's/font\.italic: true/font.italic: false/' "$INPUT_QML"
    echo "  đã sửa:"
    grep -n "font\.italic" "$INPUT_QML" | sed 's/^/    /'
else
    echo "  đã là false từ trước — không cần sửa"
    grep -n "font\.italic" "$INPUT_QML" | sed 's/^/    /'
fi

# --- 2. Cho kwin của SDDM dùng đúng scale màn hình của phiên Plasma -----------
echo
echo "=== [2/2] Đồng bộ cấu hình màn hình cho compositor của SDDM ==="
if [ ! -f "$SRC_OUTCFG" ]; then
    echo "  !! Không tìm thấy $SRC_OUTCFG — bỏ qua"
else
    mkdir -p "$SDDM_CFG"
    [ -f "$SDDM_CFG/kwinoutputconfig.json" ] && \
        cp -a "$SDDM_CFG/kwinoutputconfig.json" "$BK/kwinoutputconfig.json.sddm-cu"
    cp "$SRC_OUTCFG" "$SDDM_CFG/kwinoutputconfig.json"
    chown -R sddm:sddm "$SDDM_CFG"
    chmod 600 "$SDDM_CFG/kwinoutputconfig.json"
    echo "  đã chép -> $SDDM_CFG/kwinoutputconfig.json"
    ls -la "$SDDM_CFG/kwinoutputconfig.json" | sed 's/^/    /'
    echo "  scale sẽ áp dụng:"
    python3 - "$SDDM_CFG/kwinoutputconfig.json" <<'PY' | sed 's/^/    /'
import json, sys
for grp in json.load(open(sys.argv[1])):
    for o in grp.get("data", []):
        if "connectorName" in o:
            m = o.get("mode", {})
            print(f'{o["connectorName"]:12s} {m.get("width")}x{m.get("height")}  scale={o.get("scale")}')
PY
fi

echo
echo "=== XONG ==="
echo "Đăng xuất / reboot để thấy kết quả."
echo "Hoàn tác:  cp -a $BK/Input.qml $INPUT_QML"
echo "           rm -f $SDDM_CFG/kwinoutputconfig.json   # về lại scale tự đoán"
