#!/bin/bash
# Cài 2 gói dev KF6 còn thiếu để build plugin KWin bo góc (KDE-Rounded-Corners)
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get install -y libkirigami-dev
