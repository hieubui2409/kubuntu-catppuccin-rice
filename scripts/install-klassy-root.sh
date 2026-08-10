#!/bin/bash
# Cài window decoration Klassy (đã build sẵn trong scratchpad)
set -euo pipefail
cd /tmp/claude-1000/-home-hieubt-Documents-cleanup-pc/3eb86d77-dfc4-4584-abe3-169e5cf1cfc5/scratchpad/catppuccin/klassy/build
ninja install 2>&1 | grep -cE 'Installing|Up-to-date' | xargs -I{} echo "{} file đã cài"
