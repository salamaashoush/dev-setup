# shellcheck shell=bash
# Sourced by install.sh.

setup_productivity_apps() {
    print_header "Gaming & Productivity Applications"

    # System Monitoring (for gaming performance)
    if is_macos; then
        # Already installed with terminal tools
        :
    elif is_kde_plasma; then
        aur_install plasma-systemmonitor || true
    fi

    # App Launchers (macOS: Bolt, built by setup_bolt at the end of the run)
    if is_kde_plasma; then
        # DISABLED: Rofi setup
        # aur_install rofi-wayland || true

        # # Configure Rofi
        # if command_exists rofi && [[ -d "$CONFIGS_DIR/rofi" ]]; then
        #     ensure_directory "$HOME/.config/rofi"
        #     [[ -f "$CONFIGS_DIR/rofi/config.rasi" ]] && cp -f "$CONFIGS_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
        #     [[ -f "$CONFIGS_DIR/rofi/config-improved.rasi" ]] && cp -f "$CONFIGS_DIR/rofi/config-improved.rasi" "$HOME/.config/rofi/config-improved.rasi"

        #     # Install rofi scripts
        #     if [[ -d "$CONFIGS_DIR/rofi/scripts" ]]; then
        #         ensure_directory "$HOME/.config/rofi/scripts"
        #         cp -f "$CONFIGS_DIR/rofi/scripts/"*.sh "$HOME/.config/rofi/scripts/"
        #         chmod +x "$HOME/.config/rofi/scripts/"*.sh

        #         # Install dependencies for rofi scripts
        #         aur_install rofi-calc rofimoji rofi-power-menu wl-clipboard slurp grim swappy tesseract tesseract-data-eng || true
        #     fi
        # fi
        :
    fi

    # Gaming platforms and tools
    # macOS gets Steam from the Brewfile
    if ! is_macos; then
        # Steam and gaming essentials for Linux (optional — ~2GB+ download)
        if [[ "$INSTALL_GAMING" != true ]]; then
        print_info "Skipping gaming packages"
        else

        aur_install \
            steam \
            lutris \
            wine-staging \
            winetricks \
            gamemode lib32-gamemode \
            mangohud lib32-mangohud \
            gamescope \
            goverlay \
            protonup-qt \
            vulkan-tools \
            vkbasalt lib32-vkbasalt \
            || true

        # Only meaningful if the package actually landed — the group is created by it
        if getent group gamemode &>/dev/null; then
            sudo usermod -aG gamemode "$USER" || true
        else
            print_warning "gamemode group missing — package install likely failed"
        fi

        # GameMode config for performance
        ensure_directory "$HOME/.config/gamemode"
        cat > "$HOME/.config/gamemode.ini" << 'EOF'
[general]
renice=10
softrealtime=auto
reaper_freq=5
desiredgov=performance
igpu_desiredgov=performance
igpu_power_threshold=0.3

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high
nv_powermizer_mode=1
nv_core_clock_mhz_offset=0
nv_mem_clock_mhz_offset=0

[custom]
start=notify-send "GameMode" "Gaming optimizations enabled"
end=notify-send "GameMode" "Gaming optimizations disabled"
EOF

        # MangoHud config
        ensure_directory "$HOME/.config/MangoHud"
        cat > "$HOME/.config/MangoHud/MangoHud.conf" << 'EOF'
# MangoHud Configuration
legacy_layout=false
gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock
gpu_power
gpu_load_change
gpu_load_value=50,90
gpu_load_color=FFFFFF,FFAA7F,CC0000
cpu_stats
cpu_temp
cpu_power
cpu_mhz
cpu_load_change
core_load_change
cpu_load_value=50,90
cpu_load_color=FFFFFF,FFAA7F,CC0000
io_read
io_write
vram
ram
fps
fps_color_change
fps_value=30,60
fps_color=CC0000,FFAA7F,FFFFFF
frametime=0
frame_timing
histogram
engine_version
vulkan_driver
wine
position=top-left
round_corners=5
background_alpha=0.5
font_size=20
toggle_hud=Shift_R+F12
toggle_fps_limit=Shift_L+F1
EOF

        # Steam launch options helper
        print_info "Recommended Steam launch options:"
        print_info "  gamemoderun mangohud %command%"
        print_info "  PROTON_ENABLE_NVAPI=1 gamemoderun %command%  (for NVIDIA DLSS)"
        fi
    fi

    print_success "Productivity apps setup complete"
}
