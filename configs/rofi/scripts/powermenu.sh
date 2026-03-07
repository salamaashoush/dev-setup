#!/usr/bin/env bash
# Rofi Power Menu - KDE Plasma 6 / Wayland
# Dependencies: systemd, rofi

set -euo pipefail

THEME_STR='
window { width: 300px; }
listview { lines: 5; }
'

OPTIONS="  Lock
  Logout
  Reboot
  Shutdown
  Suspend"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "⏻ Power" -theme-str "$THEME_STR" || true)

[[ -z "$CHOICE" ]] && exit 0

confirm() {
    echo -e "Yes\nNo" | rofi -dmenu -p "Confirm $1?" -theme-str 'window{width:200px;} listview{lines:2;}'
}

case "$CHOICE" in
    *"Lock"*)
        loginctl lock-session
        ;;
    *"Logout"*)
        [[ "$(confirm logout)" == "Yes" ]] && {
            # KDE Plasma logout (qdbus6 for Plasma 6, fallback to qdbus)
            if [[ "${XDG_CURRENT_DESKTOP:-}" == *"KDE"* ]]; then
                if command -v qdbus6 &>/dev/null; then
                    qdbus6 org.kde.Shutdown /Shutdown logout
                else
                    qdbus org.kde.Shutdown /Shutdown logout
                fi
            else
                loginctl terminate-user "$USER"
            fi
        }
        ;;
    *"Reboot"*)
        [[ "$(confirm reboot)" == "Yes" ]] && systemctl reboot
        ;;
    *"Shutdown"*)
        [[ "$(confirm shutdown)" == "Yes" ]] && systemctl poweroff
        ;;
    *"Suspend"*)
        systemctl suspend
        ;;
esac
