#!/usr/bin/env bash

# Enhanced Window Switcher for Rofi
# Supports both X11 and Wayland with better formatting

# Custom theme for window switcher
THEME_STR='
window {
    width: 60%;
    height: 50%;
}
listview {
    lines: 12;
    columns: 1;
}
element {
    padding: 16px;
}
element-icon {
    size: 48px;
}
'

# Show windows with enhanced formatting
rofi \
    -show window \
    -window-format "{c:16} · {t:50} [{w:8}]" \
    -theme-str "$THEME_STR" \
    -matching fuzzy \
    -sort