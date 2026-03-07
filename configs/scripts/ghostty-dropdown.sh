#!/usr/bin/env bash
# Ghostty drop-down terminal toggle script for KDE Plasma
# Bind to F12 in: System Settings > Shortcuts > Add Command
#
# Command: ~/.local/bin/ghostty-dropdown

# Check required dependencies
# wmctrl and xdotool are X11 tools — they work under XWayland on Wayland sessions
for cmd in ghostty; do
    if ! command -v "$cmd" &>/dev/null; then
        notify-send "Ghostty Dropdown" "Missing dependency: $cmd" -u critical 2>/dev/null || \
            echo "Error: $cmd is required but not installed" >&2
        exit 1
    fi
done

# Check for window management tools (X11/XWayland required)
if ! command -v wmctrl &>/dev/null || ! command -v xdotool &>/dev/null; then
    if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
        notify-send "Ghostty Dropdown" "wmctrl/xdotool required (install for XWayland support)" -u normal 2>/dev/null
    fi
    echo "Error: wmctrl and xdotool are required but not installed" >&2
    exit 1
fi

DROPDOWN_TITLE="dropdown-terminal"

# Find existing dropdown window by title
win_id=$(wmctrl -l 2>/dev/null | grep "$DROPDOWN_TITLE" | awk '{print $1}' | head -1)

if [[ -n "$win_id" ]]; then
    # Window exists - check if it's visible/focused
    active_win=$(xdotool getactivewindow 2>/dev/null)
    dropdown_dec=$(printf "%d" "$win_id")

    if [[ "$active_win" == "$dropdown_dec" ]]; then
        # Currently focused, hide it (move off-screen or minimize)
        wmctrl -i -r "$win_id" -b add,hidden 2>/dev/null || \
        xdotool windowminimize "$win_id" 2>/dev/null || \
        wmctrl -i -r "$win_id" -e 0,0,-2000,0,0 2>/dev/null
    else
        # Not focused, show and activate
        wmctrl -i -r "$win_id" -b remove,hidden 2>/dev/null
        wmctrl -i -a "$win_id" 2>/dev/null || \
        xdotool windowactivate "$win_id" 2>/dev/null
    fi
else
    # No dropdown window exists, create one
    # Get screen dimensions
    width=""
    height=""
    if command -v xrandr &>/dev/null; then
        resolution=$(xrandr --current | grep '\*' | head -1 | awk '{print $1}')
        if [[ -n "$resolution" && "$resolution" == *x* ]]; then
            width="${resolution%x*}"
            height="${resolution#*x}"
        fi
    fi
    # Fallback to defaults if xrandr fails or returns empty
    : "${width:=1920}"
    : "${height:=1080}"

    # Calculate 40% height
    win_height=$((height * 40 / 100))

    # Start ghostty with specific geometry
    ghostty --title="$DROPDOWN_TITLE" \
            --window-width="$width" \
            --window-height="$win_height" \
            --window-padding-x=0 \
            --window-padding-y=0 &

    # Wait briefly for window to appear, then position it
    sleep 0.2
    new_win=$(wmctrl -l 2>/dev/null | grep "$DROPDOWN_TITLE" | awk '{print $1}' | head -1)
    if [[ -n "$new_win" ]]; then
        # Move to top of screen, full width
        wmctrl -i -r "$new_win" -e "0,0,0,$width,$win_height" 2>/dev/null
        # Keep above other windows
        wmctrl -i -r "$new_win" -b add,above 2>/dev/null
        # Remove window decorations (optional)
        # wmctrl -i -r "$new_win" -b add,fullscreen 2>/dev/null
    fi
fi
