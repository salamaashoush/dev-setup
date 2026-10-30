# shellcheck shell=bash
# Sourced by install.sh.

set_default_browser() {
    local browser="$1"
    print_info "Setting $browser as default browser..."

    if is_macos; then
        # macOS: Use defaultbrowser tool or open command
        case "$browser" in
            firefox)
                open -a "Firefox" --args --make-default-browser 2>/dev/null || true
                ;;
            chrome|google-chrome)
                open -a "Google Chrome" --args --make-default-browser 2>/dev/null || true
                ;;
            zen)
                # Zen browser - set via Launch Services
                defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                    '{LSHandlerURLScheme = http; LSHandlerRoleAll = "zen.browser";}' 2>/dev/null || true
                defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                    '{LSHandlerURLScheme = https; LSHandlerRoleAll = "zen.browser";}' 2>/dev/null || true
                ;;
        esac
        print_success "$browser set as default browser on macOS"
    elif is_linux; then
        # Linux: Use xdg-settings
        if command_exists xdg-settings; then
            case "$browser" in
                firefox)
                    xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
                    ;;
                chrome|google-chrome)
                    xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null || true
                    ;;
                zen)
                    xdg-settings set default-web-browser zen.desktop 2>/dev/null || \
                    xdg-settings set default-web-browser zen-browser.desktop 2>/dev/null || true
                    ;;
            esac
            print_success "$browser set as default browser on Linux"
        fi
    fi
}

setup_advanced_tools() {
    print_header "Communication & Media Tools"

    # Media tools (useful for web dev and gaming)
    if is_macos; then
        brew_install imagemagick ffmpeg
    else
        aur_install imagemagick ffmpeg || true
    fi

    # Browser (Chrome as default)
    if is_macos; then
        brew_install --cask google-chrome
    else
        aur_install google-chrome || true
    fi
    set_default_browser "chrome"

    # Communication Tools (Discord for gaming, Slack for work)
    if is_macos; then
        brew_install --cask discord slack 1password
    else
        aur_install discord slack-desktop-wayland 1password || true
    fi

    print_success "Communication & media tools setup complete"
}
