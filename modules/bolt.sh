# shellcheck shell=bash
# Sourced by install.sh.

# Bolt (https://github.com/salamaashoush/bolt) has no releases, so build it from a
# clone kept outside ~/Workspace, which leaves any development checkout alone. It
# runs last: the first build creates a self-signed signing certificate, and macOS
# asks in a dialog to trust it and to let codesign use the key.
setup_bolt() {
    is_macos || return 0
    print_header "Bolt Launcher"

    local macos_major swift_version
    macos_major=$(sw_vers -productVersion | cut -d. -f1)
    if (( macos_major < 15 )); then
        print_warning "Bolt needs macOS 15 or later (this is $(sw_vers -productVersion)); skipping"
        FAILED_PACKAGES+=("bolt (needs macOS 15+)")
        return 0
    fi

    # Package.swift declares swift-tools-version 6.2
    swift_version=$(swift --version 2>/dev/null | grep -oE 'Swift version [0-9]+\.[0-9]+' | awk '{print $3}')
    local swift_major=${swift_version%%.*} swift_minor=${swift_version#*.}
    if [[ -z "$swift_version" ]] || (( swift_major < 6 || (swift_major == 6 && swift_minor < 2) )); then
        print_warning "Bolt needs Swift 6.2 (found ${swift_version:-none}); update the Command Line Tools with softwareupdate"
        FAILED_PACKAGES+=("bolt (needs Swift 6.2)")
        return 0
    fi

    local src="${XDG_DATA_HOME:-$HOME/.local/share}/bolt"
    if [[ -d "$src/.git" ]]; then
        git -C "$src" pull --ff-only || print_warning "Could not update $src; building the existing checkout"
    elif ! git clone https://github.com/salamaashoush/bolt.git "$src"; then
        FAILED_PACKAGES+=("bolt (clone)")
        return 0
    fi

    print_info "Building Bolt. If macOS asks to trust \"Bolt Self-Signed\" or to let codesign use its key, approve it and choose Always Allow."
    if ! make -C "$src" install; then
        FAILED_PACKAGES+=("bolt (build)")
        return 0
    fi

    disable_spotlight_shortcut
    open -a Bolt || true
    print_success "Bolt installed: Cmd+Space or Option+Space"
    print_info "Window management needs Accessibility: System Settings > Privacy & Security > Accessibility > Bolt"
}

# Bolt registers Cmd+Space, which macOS keeps for Spotlight while Spotlight's
# shortcut is on. Symbolic hotkey 64 is "Show Spotlight search"; turn it back on
# under System Settings > Keyboard > Keyboard Shortcuts > Spotlight.
disable_spotlight_shortcut() {
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
        "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
    # Applies the change without logging out where this private helper exists
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
    print_info "Spotlight's Cmd+Space is off so Bolt can use it (takes effect at next login if not immediately)"
}
