#!/usr/bin/env bash
# Rofi Clipboard Manager - Wayland optimized
# Dependencies: cliphist, wl-copy, wl-paste

set -euo pipefail

THEME_STR='
window { width: 700px; }
listview { lines: 12; }
element-text { font: "CaskaydiaCove Nerd Font Mono 11"; }
'

if ! command -v cliphist &>/dev/null; then
    notify-send -u critical "Clipboard" "cliphist not installed"
    exit 1
fi

# Show clipboard history and paste selected item
selected=$(cliphist list | rofi -dmenu -p "󰅍 Clipboard" -theme-str "$THEME_STR" || true)

[[ -z "$selected" ]] && exit 0

# Decode and copy to clipboard
echo "$selected" | cliphist decode | wl-copy
