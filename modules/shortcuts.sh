# shellcheck shell=bash
# Sourced by install.sh.

setup_kde_rofi_shortcuts() {
    # Setup KDE Plasma custom shortcuts for Rofi
    # KDE Plasma 6 uses kglobalshortcutsrc with custom service files

    if ! is_kde_plasma; then
        return 0
    fi

    print_info "Configuring Rofi shortcuts for KDE Plasma..."

    # Create desktop files for rofi commands
    ensure_directory "$HOME/.local/share/applications"

    # Rofi App Launcher
    cat > "$HOME/.local/share/applications/rofi-launcher.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Launcher
Comment=Application launcher
Exec=rofi -show drun
Icon=rofi
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Window Switcher
    cat > "$HOME/.local/share/applications/rofi-window.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Window Switcher
Comment=Switch between windows
Exec=rofi -show window
Icon=rofi
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Clipboard
    cat > "$HOME/.local/share/applications/rofi-clipboard.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Clipboard
Comment=Clipboard history
Exec=~/.config/rofi/scripts/clipboard.sh
Icon=edit-paste
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Power Menu
    cat > "$HOME/.local/share/applications/rofi-powermenu.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Power Menu
Comment=Power options
Exec=~/.config/rofi/scripts/powermenu.sh
Icon=system-shutdown
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Screenshot
    cat > "$HOME/.local/share/applications/rofi-screenshot.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Screenshot
Comment=Screenshot tool
Exec=~/.config/rofi/scripts/screenshot.sh
Icon=camera-photo
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

    # Configure shortcuts via kglobalshortcutsrc
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    # Alt+Space for Rofi launcher (main)
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-launcher.desktop --key _launch "Alt+Space,Alt+Space,Rofi Launcher"

    # Alt+Tab alternative with Rofi window switcher
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-window.desktop --key _launch "Alt+Shift+Tab,Alt+Shift+Tab,Rofi Window Switcher"

    # Alt+V for clipboard history
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-clipboard.desktop --key _launch "Alt+V,Alt+V,Rofi Clipboard"

    # Alt+Shift+P for power menu
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-powermenu.desktop --key _launch "Alt+Shift+P,Alt+Shift+P,Rofi Power Menu"

    # Print Screen for screenshot
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-screenshot.desktop --key _launch "Print,Print,Rofi Screenshot"

    # Reload KDE shortcuts daemon to apply changes
    if command_exists kquitapp6; then
        kquitapp6 kglobalaccel 2>/dev/null && sleep 1 && kglobalaccel6 &>/dev/null &
    fi

    print_success "Rofi shortcuts configured"
    print_info "  Alt+Space     → App Launcher"
    print_info "  Alt+V         → Clipboard History"
    print_info "  Alt+Shift+P   → Power Menu"
    print_info "  Print         → Screenshot"
}

setup_keyboard_shortcuts() {
    print_header "Keyboard Shortcuts & System Integration"

    if is_macos; then
        setup_macos_shortcuts
    elif is_kde_plasma; then
        setup_plasma_shortcuts
    fi

    # Create shortcuts documentation
    create_shortcuts_documentation
}

setup_macos_shortcuts() {
    print_info "Setting up macOS keyboard shortcuts..."

    # Global shortcuts for apps
    defaults write -g NSUserKeyEquivalents -dict-add "Open Kitty" "@~t"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Zed" "@~c"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Finder" "@~f"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Google Chrome" "@~b"

    # Mission Control shortcuts
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>18</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>19</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>123</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>124</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"

    print_info "macOS shortcuts configured:"
    print_info "  Cmd+Opt+T → Kitty Terminal"
    print_info "  Cmd+Opt+C → Zed"
    print_info "  Cmd+Opt+F → Finder"
    print_info "  Cmd+Opt+B → Browser"
    print_info "  Ctrl+Up/Down/Left/Right → Mission Control"

    # Rectangle info
    if command_exists rectangle || [[ -d "/Applications/Rectangle.app" ]]; then
        print_info "Rectangle window management shortcuts:"
        print_info "  Ctrl+Opt+Left/Right → Tile window"
        print_info "  Ctrl+Opt+Enter → Maximize"
        print_info "  Ctrl+Opt+C → Center"
    fi
}

setup_plasma_shortcuts() {
    print_info "Setting up KDE Plasma 6 keyboard shortcuts..."

    # Use kwriteconfig6 if available (Plasma 6), fallback to kwriteconfig5
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    if command_exists "$kwrite_cmd"; then
        # Application shortcuts - use kwriteconfig with desktop file as group name
        "$kwrite_cmd" --file kglobalshortcutsrc --group "com.mitchellh.ghostty.desktop" --key _launch "Ctrl+Alt+T,Ctrl+Alt+T,Launch Ghostty"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "dev.zed.Zed.desktop" --key _launch "Ctrl+Alt+C,Ctrl+Alt+C,Launch Zed"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "org.kde.dolphin.desktop" --key _launch "Ctrl+Alt+F,Ctrl+Alt+F,Launch Dolphin"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "google-chrome.desktop" --key _launch "Ctrl+Alt+B,Ctrl+Alt+B,Launch Chrome"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "org.kde.plasma-systemmonitor.desktop" --key _launch "Ctrl+Alt+M,Ctrl+Alt+M,Launch System Monitor"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "rofi-launcher.desktop" --key _launch "Alt+Space,Alt+Space,Rofi Launcher"

        # Setup Rofi desktop files
        setup_kde_rofi_shortcuts

        # Window tiling (KDE defaults)
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Top" "Meta+Up,Meta+Up,Quick Tile Window to the Top"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Bottom" "Meta+Down,Meta+Down,Quick Tile Window to the Bottom"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Left" "Meta+Left,Meta+Left,Quick Tile Window to the Left"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Right" "Meta+Right,Meta+Right,Quick Tile Window to the Right"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Maximize" "Meta+PgUp,Meta+PgUp,Maximize Window"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Minimize" "Meta+PgDown,Meta+PgDown,Minimize Window"

        # Desktop switching
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Ctrl+F1,Ctrl+F1,Switch to Desktop 1"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Ctrl+F2,Ctrl+F2,Switch to Desktop 2"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Ctrl+F3,Ctrl+F3,Switch to Desktop 3"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Ctrl+F4,Ctrl+F4,Switch to Desktop 4"

        # Reload KDE shortcuts daemon to apply changes
        # This is critical for shortcuts to take effect without logout
        if command_exists kquitapp6; then
            kquitapp6 kglobalaccel 2>/dev/null
            sleep 2
            # kglobalaccel auto-restarts via systemd, but we can force it
            systemctl --user restart plasma-kglobalaccel.service 2>/dev/null || kstart6 kglobalaccel6 2>/dev/null &
        elif command_exists kquitapp5; then
            kquitapp5 kglobalaccel 2>/dev/null
            sleep 2
            kstart5 kglobalaccel5 2>/dev/null &
        fi

        print_info "KDE Plasma shortcuts configured:"
        print_info "  F12        → Dropdown Terminal"
        print_info "  Ctrl+Alt+T → Terminal"
        print_info "  Ctrl+Alt+C → Zed"
        print_info "  Ctrl+Alt+F → File Manager"
        print_info "  Alt+Space  → KRunner/Rofi"
        print_info "  Meta+Arrows → Window Tiling"
    fi

    # DISABLED: Rofi shortcuts info
    # # Rofi shortcuts info
    # if command_exists rofi && [[ -d "$HOME/.config/rofi/scripts" ]]; then
    #     print_info "Rofi launcher shortcuts available:"
    #     print_info "  Alt+Space → App launcher"
    #     print_info "  Alt+Shift+C → Clipboard history"
    #     print_info "  Alt+Shift+P → Power menu"
    #     print_info "  Alt+Shift+D → Developer menu"
    # fi
}

create_shortcuts_documentation() {
    print_info "Creating shortcuts documentation..."

    local doc_file="$HOME/.config/keyboard-shortcuts-reference.md"

    cat > "$doc_file" << 'EOF'
# Keyboard Shortcuts Reference

## Quick Access
This file contains all keyboard shortcuts configured by the dev setup.

### Platform-Specific Shortcuts

EOF

    if is_macos; then
        cat >> "$doc_file" << 'EOF'
#### macOS Shortcuts

**System**
- `Cmd+Space` / `Option+Space` → Bolt (launcher, clipboard history, window management)
- `Cmd+Opt+T` → Ghostty Terminal
- `Cmd+Opt+C` → Zed

**Window Management (Rectangle)**
- `Ctrl+Opt+Left` → Left half
- `Ctrl+Opt+Right` → Right half
- `Ctrl+Opt+Enter` → Maximize
- `Ctrl+Opt+Up` → Top half
- `Ctrl+Opt+Down` → Bottom half

**Mission Control**
- `Ctrl+Up` → Mission Control
- `Ctrl+Down` → Application Windows
- `Ctrl+Left/Right` → Switch Spaces

EOF
    elif is_kde_plasma; then
        cat >> "$doc_file" << 'EOF'
#### KDE Plasma Shortcuts

**Applications**
- `Ctrl+Alt+T` → Ghostty Terminal
- `Ctrl+Alt+C` → Zed
- `Ctrl+Alt+F` → File Manager
- `Ctrl+Alt+B` → Browser
- `Ctrl+Alt+M` → System Monitor

**Launchers**
- `Alt+Space` → Rofi (app launcher)
- `Alt+F2` → KRunner
- `Alt+Shift+C` → Clipboard History
- `Alt+Shift+P` → Power Menu
- `Alt+Shift+D` → Developer Menu

**Window Management**
- `Meta+Left/Right` → Tile window
- `Meta+Up` → Maximize
- `Meta+Down` → Minimize
- `Alt+Tab` → Switch windows

**Virtual Desktops**
- `Ctrl+F1-F4` → Switch desktop
- `Ctrl+Shift+F1-F4` → Move window to desktop

EOF
    fi

    cat >> "$doc_file" << 'EOF'
### Terminal Shortcuts (Ghostty)

- `Ctrl+Shift+T` → New tab
- `Ctrl+Shift+N` → New window
- `Ctrl+Shift+W` → Close tab
- `Ctrl+Tab` → Next tab
- `Ctrl+Shift+Tab` → Previous tab
- `Ctrl+Shift+C` → Copy
- `Ctrl+Shift+V` → Paste

### Editor Shortcuts (Zed)

- `Cmd/Ctrl+P` → Quick file open
- `Cmd/Ctrl+Shift+P` → Command palette
- `Cmd/Ctrl+B` → Toggle left dock
- `Cmd/Ctrl+J` → Toggle bottom dock (terminal)
- `F12` → Go to definition
- `Shift+F12` → Find references

### Git (lazygit)

- `lg` → Open lazygit
- `Space` → Stage/unstage
- `c` → Commit
- `p` → Push
- `P` → Pull

For complete shortcuts documentation, see the docs/shortcuts/ directory in your dev-setup repository.
EOF

    print_success "Shortcuts reference created at: $doc_file"
}
