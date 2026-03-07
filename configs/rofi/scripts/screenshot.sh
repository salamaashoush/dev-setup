#!/usr/bin/env bash
# Rofi Screenshot Tool - Wayland/KDE Plasma 6 optimized
# Dependencies: grim, slurp, wl-copy, libnotify

set -euo pipefail

# Screenshot directory
SCREENSHOT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename
FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Options
OPTIONS="󰹑  Full Screen
󰩬  Select Area
󰔝  Full Screen (5s delay)
󰆏  Full Screen → Clipboard
󰆐  Select Area → Clipboard"

# Custom theme
THEME_STR='
window { width: 400px; }
listview { lines: 5; }
'

# Show options
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰄀 Screenshot" -theme-str "$THEME_STR" || true)

# Exit if no choice
[[ -z "$CHOICE" ]] && exit 0

notify() {
    notify-send -i camera-photo "Screenshot" "$1" -t 3000
}

case "$CHOICE" in
    *"Full Screen → Clipboard"*)
        grim - | wl-copy
        notify "Full screen copied to clipboard"
        ;;
    *"Select Area → Clipboard"*)
        grim -g "$(slurp -d)" - | wl-copy
        notify "Selected area copied to clipboard"
        ;;
    *"Full Screen"*"delay"*)
        notify "Taking screenshot in 5 seconds..."
        sleep 5
        grim "$FILENAME"
        notify "Saved to $FILENAME"
        ;;
    *"Full Screen"*)
        sleep 0.2  # Brief delay to let rofi close
        grim "$FILENAME"
        notify "Saved to $FILENAME"
        ;;
    *"Select Area"*)
        grim -g "$(slurp -d)" "$FILENAME"
        notify "Saved to $FILENAME"
        ;;
esac
