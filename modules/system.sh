# shellcheck shell=bash
# Sourced by install.sh.

setup_system_optimizations() {
    print_header "System Optimizations"

    if is_macos; then
        setup_macos_optimizations
    elif is_arch_linux; then
        setup_arch_linux_optimizations
    fi
}

setup_macos_optimizations() {
    print_info "Applying macOS optimizations (safe, reversible settings)..."

    # All settings below are safe and can be reverted by:
    # defaults delete <domain> <key>

    # ---- Dock Settings (visual only, safe) ----
    # Faster dock auto-hide animation (default is ~0.7)
    defaults write com.apple.dock autohide-time-modifier -float 0.5 2>/dev/null || true
    # Faster Mission Control animation
    defaults write com.apple.dock expose-animation-duration -float 0.5 2>/dev/null || true

    # ---- Keyboard Settings (safe, common preferences) ----
    # Faster key repeat (6 = fast, default is usually higher)
    defaults write NSGlobalDomain KeyRepeat -int 6 2>/dev/null || true
    # Shorter delay before key repeat starts (25 = quick, default is ~35)
    defaults write NSGlobalDomain InitialKeyRepeat -int 25 2>/dev/null || true

    # ---- Finder Settings (visual/UX, safe) ----
    # Show path bar at bottom of Finder
    defaults write com.apple.finder ShowPathbar -bool true 2>/dev/null || true
    # Show status bar at bottom of Finder
    defaults write com.apple.finder ShowStatusBar -bool true 2>/dev/null || true
    # Don't warn when changing file extensions
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false 2>/dev/null || true
    # Show hidden files (useful for developers)
    defaults write com.apple.finder AppleShowAllFiles -bool true 2>/dev/null || true

    # ---- Screenshot Settings (safe) ----
    # Save screenshots to dedicated folder
    ensure_directory "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots" 2>/dev/null || true
    # Disable shadow in screenshots (cleaner look)
    defaults write com.apple.screencapture disable-shadow -bool true 2>/dev/null || true
    # Use PNG format (high quality)
    defaults write com.apple.screencapture type png 2>/dev/null || true

    # ---- Safari Developer Settings (if Safari is used) ----
    # Enable Safari developer menu
    defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null || true

    # ---- Help Viewer (minor, safe) ----
    # Help viewer windows non-floating
    defaults write com.apple.helpviewer DevMode -bool true 2>/dev/null || true

    # ---- Apply changes by restarting affected apps ----
    print_info "Restarting Dock and Finder to apply changes..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true

    # Note: We intentionally do NOT disable:
    # - SIP (System Integrity Protection)
    # - Gatekeeper
    # - Power management aggressively
    # - Any system security features

    print_success "macOS optimizations applied (all changes are reversible)"
    print_info "To revert any setting: defaults delete <domain> <key>"
}

setup_arch_linux_optimizations() {
    print_info "Applying Arch Linux optimizations..."

    # Performance optimizations — skip on CachyOS (it ships its own tuned settings)
    if is_cachyos; then
        print_info "CachyOS detected — skipping sysctl/udev tuning (already optimized by cachyos-settings)"
    else
        if [[ ! -f /etc/sysctl.d/99-dev-setup-performance.conf ]]; then
            sudo tee /etc/sysctl.d/99-dev-setup-performance.conf > /dev/null << 'EOF'
# Dev-setup performance optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
            print_success "Performance sysctl settings applied"
        else
            print_info "Performance sysctl settings already configured"
        fi

        # IO scheduler (idempotent)
        if [[ ! -f /etc/udev/rules.d/60-ioschedulers.rules ]]; then
            echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null
            print_success "IO scheduler rule applied"
        else
            print_info "IO scheduler rule already configured"
        fi

        # Network optimizations (idempotent - only create if not exists)
        if [[ ! -f /etc/sysctl.d/99-dev-setup-network.conf ]]; then
            sudo tee /etc/sysctl.d/99-dev-setup-network.conf > /dev/null << 'EOF'
# Dev-setup network optimizations
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF
            print_success "Network sysctl settings applied"
        else
            print_info "Network sysctl settings already configured"
        fi
    fi

    # Graphics and audio — skip zram-generator on CachyOS (already configured)
    if is_cachyos; then
        aur_install cpupower libva-utils || true
    else
        aur_install cpupower zram-generator libva-utils || true
    fi

    # Audio setup with PipeWire (important for Plasma 6)
    aur_install pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber gst-plugin-pipewire lib32-pipewire lib32-pipewire-jack || true
    systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service || true

    # GPU drivers. These are independent checks, not a chain — hybrid systems
    # (discrete NVIDIA + AMD/Intel iGPU) need drivers for BOTH.
    if has_nvidia_gpu; then
        print_info "NVIDIA GPU detected"

        if nvidia_requires_open_modules; then
            print_info "Blackwell-class GPU (RTX 50 / GB2xx) — open kernel modules are mandatory"
            if pacman -Qq nvidia-dkms &>/dev/null || pacman -Qq nvidia &>/dev/null; then
                print_warning "Proprietary nvidia modules are installed but do not support this GPU."
                print_warning "Replace with nvidia-open-dkms (or a *-nvidia-open kernel package)."
            fi
        fi

        # Install NVIDIA drivers — CachyOS ships modules with its kernel packages
        if is_cachyos; then
            if pacman -Qq 2>/dev/null | grep -q 'nvidia-open'; then
                print_info "CachyOS kernel already provides the open NVIDIA modules"
            elif nvidia_requires_open_modules; then
                print_info "Installing open NVIDIA modules for CachyOS"
                sudo pacman -S --needed --noconfirm nvidia-open-dkms 2>/dev/null || \
                    print_warning "Install a linux-cachyos-*-nvidia-open kernel instead"
            fi
            sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils nvidia-settings 2>/dev/null || true
        elif nvidia_requires_open_modules; then
            aur_install nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings || true
        elif command_exists nvidia-inst; then
            # EndeavourOS nvidia installer
            sudo nvidia-inst --32 -f || true
        else
            aur_install nvidia nvidia-utils lib32-nvidia-utils nvidia-settings || true
        fi

        # Extra packages for Wayland/gaming
        aur_install \
            libva-nvidia-driver \
            egl-wayland \
            || true

        # NVIDIA gaming environment variables (safe, user-level only)
        # Ref: https://wiki.archlinux.org/title/Hardware_raytracing
        # Ref: https://github.com/jp7677/dxvk-nvapi
        ensure_directory "$HOME/.config/environment.d"
        cat > "$HOME/.config/environment.d/nvidia-gaming.conf" << 'EOF'
# NVIDIA Gaming optimizations (user-level, safe)
# Updated for RTX 50 series / open drivers (2025)

# Shader cache - prevent cleanup for large games
# (cache is enabled by default, this just prevents pruning)
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# DLSS support in Proton (required for DLSS to work)
PROTON_ENABLE_NVAPI=1

# Note: VKD3D_CONFIG=dxr is no longer needed (DXR enabled by default)
# Note: __GL_THREADED_OPTIMIZATIONS can hurt some apps, use per-game if needed
EOF

        print_success "NVIDIA gaming env vars configured"
    fi

    if has_amd_gpu; then
        print_info "AMD GPU detected (discrete or integrated)"
        aur_install mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon || true
    fi

    if has_intel_gpu; then
        print_info "Intel GPU detected"
        aur_install mesa vulkan-intel lib32-mesa lib32-vulkan-intel || true
    fi

    # KDE Plasma optimizations
    if is_kde_plasma; then
        setup_kde_plasma_optimizations
    fi

    # Backup pacman.conf before modifications
    if [[ ! -f /etc/pacman.conf.bak ]]; then
        sudo cp /etc/pacman.conf /etc/pacman.conf.bak
        print_info "Created backup: /etc/pacman.conf.bak"
    fi

    # EndeavourOS optimizations
    if is_endeavouros; then
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf || true
        sudo pacman -Sy || true
        aur_install welcome eos-update-notifier eos-update-notifier-plasma || true
    fi

    # Optimize pacman — CachyOS already has these enabled
    if ! is_cachyos; then
        sudo sed -i 's/#Color/Color/' /etc/pacman.conf
        sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
        sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
    else
        print_info "CachyOS detected — skipping pacman.conf modifications (already optimized)"
    fi

    print_success "Arch Linux optimizations applied"
}

setup_kde_plasma_optimizations() {
    print_info "Applying KDE Plasma 6 optimizations..."

    # Configure environment for Wayland
    ensure_directory "$HOME/.config/environment.d"

    # Base Wayland environment (safe for all GPUs)
    cat > "$HOME/.config/environment.d/wayland.conf" << 'EOF'
# Wayland environment variables for KDE Plasma 6
QT_QPA_PLATFORM=wayland;xcb
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
MOZ_ENABLE_WAYLAND=1
SDL_VIDEODRIVER=wayland,x11
_JAVA_AWT_WM_NONREPARENTING=1
CLUTTER_BACKEND=wayland
GDK_BACKEND=wayland,x11
EOF

    # NOTE: NVIDIA Wayland env vars (GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME, LIBVA_DRIVER_NAME)
    # are NO LONGER NEEDED with nvidia-utils 555+ (they're auto-detected).
    # Setting them manually can cause black screen issues on KDE Plasma 6.
    # See: https://wiki.archlinux.org/title/NVIDIA

    # Electron apps Wayland support
    cat > "$HOME/.config/electron-flags.conf" << 'EOF'
--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-features=WaylandWindowDecorations
EOF

    # Chrome/Chromium Wayland flags (both files for compatibility)
    local chrome_flags='--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-features=WaylandWindowDecorations'

    echo "$chrome_flags" > "$HOME/.config/chromium-flags.conf"
    echo "$chrome_flags" > "$HOME/.config/chrome-flags.conf"
    echo "$chrome_flags" > "$HOME/.config/google-chrome-flags.conf"

    # Configure KDE settings via kwriteconfig5/kwriteconfig6
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    if command_exists "$kwrite_cmd"; then
        print_info "Configuring KDE settings..."

        # NOTE: Do NOT set Compositing Backend - KDE Plasma 6 auto-detects the correct
        # backend for Wayland. Forcing OpenGL can cause black screen issues with NVIDIA.
        # See: https://discuss.kde.org/t/if-anybody-want-to-try-to-hunt-down-the-wayland-black-screen-in-plasma-6-with-nvidia-look-here/11607

        # Animation speed (0.5 = faster, 1.0 = normal, 0 = instant) - safe to set
        "$kwrite_cmd" --file kdeglobals --group KDE --key AnimationDurationFactor 0.5 2>/dev/null || true

        # Desktop effects - only disable problematic ones, don't force enable
        "$kwrite_cmd" --file kwinrc --group Plugins --key wobblywindowsEnabled false 2>/dev/null || true

        print_success "KDE settings applied"
    fi

    # Install essential KDE tools only (minimal set)
    print_info "Installing KDE utilities..."
    aur_install \
        plasma-systemmonitor \
        kdeconnect \
        kinfocenter \
        kde-gtk-config \
        breeze-gtk \
        kvantum \
        2>/dev/null || true

    # Copy Plasma layout if available
    if [[ -f "$CONFIGS_DIR/plasma-layout.js" ]]; then
        local plasma_dir="$HOME/.local/share/plasma/layout-templates/dev-setup"
        ensure_directory "$plasma_dir/contents"
        cp -f "$CONFIGS_DIR/plasma-layout.js" "$plasma_dir/contents/layout.js"
        print_info "Plasma layout template installed. Apply via: Right-click desktop → Enter Edit Mode → Add Panel → Templates"
    fi

    # Enable PipeWire services (important for Plasma 6 audio)
    print_info "Enabling PipeWire audio services..."
    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

    print_success "KDE Plasma 6 optimizations applied"
}
