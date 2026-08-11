#!/bin/sh
# Bật ibus (Bamboo) cho mọi app trên Plasma Wayland — im-config không chạy trên Wayland
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export GLFW_IM_MODULE=ibus
