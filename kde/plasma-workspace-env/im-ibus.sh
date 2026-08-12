#!/bin/sh
# Plasma Wayland: input method do KWin quản lý (kwinrc [Wayland] InputMethod).
# KHÔNG đặt GTK_IM_MODULE / QT_IM_MODULE — app Wayland dùng giao thức text-input,
# đặt hai biến này sẽ ép chúng quay về đường IM module kiểu X11 và gây lỗi.
# XMODIFIERS vẫn cần cho app chạy qua XWayland (ibus-daemon được khởi động với --xim).
export XMODIFIERS=@im=ibus
