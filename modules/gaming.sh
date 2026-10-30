# shellcheck shell=bash
# Sourced by install.sh.

setup_game_development() {
    print_header "Game Development"

    [[ "$INSTALL_GAMEDEV" != true ]] && { print_info "Skipping game development tools"; return 0; }

    # macOS gets these from the Brewfile
    is_macos && return 0

    # Engines and content tools
    aur_install godot blender || true

    # Vulkan: loader, headers, and the validation layers you actually debug against
    aur_install \
        vulkan-headers \
        vulkan-tools \
        vulkan-validation-layers lib32-vulkan-validation-layers \
        vulkan-icd-loader lib32-vulkan-icd-loader \
        spirv-tools \
        glslang \
        shaderc \
        || true

    # Graphics debugging and profiling
    aur_install renderdoc || true
    aur_install tracy || print_info "tracy unavailable — skip or build from source"

    # System libraries Rust engines (Bevy, macroquad, winit) link against on Linux
    aur_install \
        alsa-lib \
        libxkbcommon \
        libx11 libxi libxcursor libxrandr libxinerama \
        wayland wayland-protocols \
        systemd-libs \
        fontconfig \
        || true

    # Native debugging
    aur_install lldb gdb || true

    print_success "Game development tools installed"
    print_info "Vulkan validation: VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation <binary>"
    print_info "Verify the stack with: vulkaninfo --summary"
}

setup_cachyos_tuning() {
    is_linux || return 0
    is_arch_linux || return 0

    print_header "Hardware Tuning"

    # ---- CPU frequency driver ----
    local drv epp
    drv=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo unknown)
    epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo n/a)
    print_info "CPU scaling driver: $drv (EPP: $epp)"
    if [[ "$drv" == "acpi-cpufreq" ]] && grep -qi 'amd' /proc/cpuinfo; then
        print_warning "amd_pstate is not active — add amd_pstate=active to the kernel cmdline for better scaling"
    fi

    # ---- Asymmetric X3D CCD switching ----
    if has_amd_x3d_switch; then
        print_step "Installing x3d-mode helper..."
        # Root-owned in /usr/local/bin: it writes to sysfs via sudo, so it must not
        # be user-writable.
        sudo install -o root -g root -m 755 \
            "$CONFIGS_DIR/scripts/x3d-mode.sh" /usr/local/bin/x3d-mode
        print_success "x3d-mode installed"
        print_info "Current mode: $(cat /sys/bus/platform/drivers/amd_x3d_vcache/*/amd_x3d_mode 2>/dev/null)"
        print_info "  x3d-mode cache      -> prefer V-Cache CCD (gaming)"
        print_info "  x3d-mode frequency  -> prefer high-clock CCD (compiling)"

        setup_x3d_gamemode_hook
    fi

    # ---- sched_ext ----
    if has_sched_ext; then
        print_info "sched_ext is available in this kernel"
        if command_exists scx_loader && systemctl list-unit-files scx_loader.service &>/dev/null; then
            if [[ $(systemctl is-enabled scx_loader.service 2>/dev/null) != enabled ]]; then
                echo
                read -p "Enable scx_loader (pluggable schedulers, e.g. scx_lavd for gaming)? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sudo systemctl enable --now scx_loader.service || print_warning "Could not enable scx_loader"
                    print_success "scx_loader enabled"
                fi
            else
                print_info "scx_loader already enabled"
            fi
            command_exists scx-manager && print_info "Pick a scheduler with: scx-manager (GUI)"
            print_info "Or try one directly: sudo scx_lavd   (latency-tuned, good for games)"
        fi
    fi

    print_success "Hardware tuning complete"
}

# Switch to the V-Cache CCD while a game runs, back to high-clock when it exits.
# Needs a NOPASSWD sudoers entry, so it is strictly opt-in.
setup_x3d_gamemode_hook() {
    local gm_ini="$HOME/.config/gamemode.ini"
    command_exists gamemoded || return 0
    [[ -f "$gm_ini" ]] || return 0
    grep -q 'x3d-mode' "$gm_ini" && { print_info "GameMode X3D hook already configured"; return 0; }

    echo
    print_warning "Optional: switch to the V-Cache CCD automatically while games run."
    print_warning "This requires a sudoers rule letting your user run exactly two commands"
    print_warning "without a password: '/usr/local/bin/x3d-mode cache' and '... frequency'."
    read -p "Configure this? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && { print_info "Skipped X3D GameMode hook"; return 0; }

    local sudoers=/etc/sudoers.d/10-x3d-mode
    sudo tee "$sudoers" > /dev/null << EOF
$USER ALL=(root) NOPASSWD: /usr/local/bin/x3d-mode cache, /usr/local/bin/x3d-mode frequency
EOF
    sudo chmod 0440 "$sudoers"

    if ! sudo visudo -c -f "$sudoers" &>/dev/null; then
        sudo rm -f "$sudoers"
        print_error "sudoers validation failed — rule removed, no changes made"
        return 1
    fi

    backup_file "$gm_ini"
    sed -i 's|^start=.*|&\nstart=/usr/local/bin/x3d-mode cache|; s|^end=.*|&\nend=/usr/local/bin/x3d-mode frequency|' "$gm_ini"
    print_success "GameMode will switch CCD preference automatically"
}

setup_gaming_network() {
    is_linux || return 0

    print_header "Gaming Network"

    # upnpc talks to the router's IGD; gamenet needs it to diagnose the router layer
    if ! command_exists upnpc; then
        print_step "Installing miniupnpc..."
        aur_install miniupnpc || print_warning "Could not install miniupnpc"
    fi

    for tool in game-firewall gamenet; do
        link_config "scripts/${tool}.sh" "$HOME/.local/bin/$tool"
    done
    print_success "Installed game-firewall and gamenet to ~/.local/bin"

    if ! command_exists ufw; then
        print_info "ufw not installed - nothing is blocking inbound game traffic"
    elif [[ $(systemctl is-active ufw 2>/dev/null) != active ]]; then
        print_info "ufw installed but inactive - run 'sudo game-firewall' if you enable it later"
    else
        print_warning "ufw is active and defaults to dropping inbound connections."
        print_info "This blocks hosted games AND the router's UPnP replies, so games cannot"
        print_info "forward their own ports either. Both fail silently."
        echo
        read -p "Open the firewall for multiplayer game hosting? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo "$HOME/.local/bin/game-firewall" || print_warning "game-firewall failed"
        else
            print_info "Skipped. Run 'sudo game-firewall' later."
        fi
    fi

    echo
    print_info "Router side: enable UPnP in your router admin UI, and give this machine"
    print_info "a static DHCP lease. Then verify the whole chain with:  gamenet check"

    print_success "Gaming network setup complete"
}
