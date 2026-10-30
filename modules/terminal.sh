# shellcheck shell=bash
# Sourced by install.sh.

install_nerd_fonts() {
    print_info "Installing Nerd Fonts..."

    # Required fonts used by configs:
    # - CaskaydiaCove Nerd Font (primary - terminal, editors, rofi)
    # - JetBrainsMono Nerd Font (fallback)
    # - Symbols Nerd Font (icon fallback)

    if is_macos; then
        # macOS - use Homebrew casks
        print_info "Installing fonts via Homebrew..."
        brew_install --cask \
            font-caskaydia-cove-nerd-font \
            font-jetbrains-mono-nerd-font \
            font-symbols-only-nerd-font \
            font-fira-code-nerd-font
    else
        # Linux (Arch) - use pacman/yay
        if command_exists paru || command_exists yay; then
            print_info "Installing fonts via AUR helper..."
            aur_install \
                ttf-cascadia-code-nerd \
                ttf-jetbrains-mono-nerd \
                ttf-nerd-fonts-symbols \
                ttf-firacode-nerd \
                2>/dev/null || true
        elif command_exists pacman; then
            print_info "Installing fonts via pacman..."
            sudo pacman -S --needed --noconfirm \
                ttf-cascadia-code-nerd \
                ttf-jetbrains-mono-nerd \
                ttf-nerd-fonts-symbols \
                ttf-firacode-nerd \
                2>/dev/null || true
        else
            # Fallback: manual installation from GitHub releases
            print_info "Installing fonts manually from GitHub..."
            install_nerd_fonts_manual
        fi
    fi

    # Refresh font cache on Linux
    if ! is_macos && command_exists fc-cache; then
        print_info "Refreshing font cache..."
        fc-cache -fv >/dev/null 2>&1 || true
    fi

    # Verify installation
    verify_nerd_fonts
}

install_nerd_fonts_manual() {
    # Manual installation for systems without package managers
    local font_dir
    local nerd_fonts_version="v3.3.0"
    local base_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_fonts_version}"

    if is_macos; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi

    ensure_directory "$font_dir"
    local temp_dir
    temp_dir=$(mktemp -d)

    print_info "Downloading Nerd Fonts to $temp_dir..."

    # Download and extract fonts
    for font in "CascadiaCode" "JetBrainsMono" "NerdFontsSymbolsOnly"; do
        local zip_file="$temp_dir/${font}.zip"
        print_info "Downloading ${font}..."
        if curl -fsSL "${base_url}/${font}.zip" -o "$zip_file"; then
            unzip -o -q "$zip_file" -d "$font_dir" 2>/dev/null || true
            rm -f "$zip_file"
        else
            print_warning "Failed to download ${font}"
        fi
    done

    rm -rf "$temp_dir"

    # Remove Windows-specific fonts
    find "$font_dir" -name "*Windows*" -delete 2>/dev/null || true
}

verify_nerd_fonts() {
    print_info "Verifying Nerd Font installation..."

    local missing_fonts=()
    local fonts_to_check=(
        "CaskaydiaCove Nerd Font"
        "JetBrainsMono Nerd Font"
    )

    if is_macos; then
        # macOS font verification
        for font in "${fonts_to_check[@]}"; do
            if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "${font%% *}"; then
                # Try alternative check
                if ! fc-list 2>/dev/null | grep -qi "${font%% *}"; then
                    missing_fonts+=("$font")
                fi
            fi
        done
    else
        # Linux font verification using fc-list
        if command_exists fc-list; then
            for font in "${fonts_to_check[@]}"; do
                if ! fc-list | grep -qi "${font%% *}"; then
                    missing_fonts+=("$font")
                fi
            done
        fi
    fi

    if [[ ${#missing_fonts[@]} -eq 0 ]]; then
        print_success "All required Nerd Fonts are installed"
    else
        print_warning "Some fonts may be missing: ${missing_fonts[*]}"
        print_info "You may need to restart your terminal or log out/in for fonts to appear"
    fi
}

install_tokyo_night_themes() {
    local theme_base="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras"

    # Download themes for installed tools
    if command_exists kitty && [[ -d "$HOME/.config/kitty" ]]; then
        curl -fsSL "$theme_base/kitty/tokyonight_storm.conf" -o "$HOME/.config/kitty/tokyonight_storm.conf" 2>/dev/null || true
    fi

    if command_exists bat; then
        ensure_directory "$HOME/.config/bat/themes"
        curl -fsSL "$theme_base/sublime/tokyonight_storm.tmTheme" -o "$HOME/.config/bat/themes/tokyonight_storm.tmTheme" 2>/dev/null || true
        # Install bat config
        if [[ -f "$CONFIGS_DIR/bat/config" ]]; then
            cp -f "$CONFIGS_DIR/bat/config" "$HOME/.config/bat/config"
        fi
        bat cache --build >/dev/null 2>&1 || true
    fi

    if command_exists lazygit && [[ -d "$HOME/.config/lazygit" ]]; then
        # The theme is already integrated in our lazygit.yml config
        :
    fi

    if command_exists delta; then
        ensure_directory "$HOME/.config/git"
        curl -fsSL "$theme_base/delta/tokyonight_storm.gitconfig" -o "$HOME/.config/git/delta-tokyonight.gitconfig" 2>/dev/null || true
    fi

    if command_exists yazi && [[ -d "$HOME/.config/yazi" ]]; then
        # Do NOT overwrite theme.toml here -- this repo ships its own fixed
        # configs/yazi/theme.toml (current [mgr]/[icon] schema). Only fetch the
        # syntect highlighting theme it references via syntect_theme.
        curl -fsSL "$theme_base/sublime/tokyonight_storm.tmTheme" -o "$HOME/.config/yazi/tokyonight_storm.tmTheme" 2>/dev/null || true
    fi


    if command_exists gitui && [[ -d "$HOME/.config/gitui" ]]; then
        curl -fsSL "$theme_base/gitui/tokyonight_storm.ron" -o "$HOME/.config/gitui/theme.ron" 2>/dev/null || true
    fi
}

setup_terminal_and_shell() {
    print_header "Terminal & Shell Setup"

    # Install terminal emulators (Ghostty is primary)
    if is_macos; then
        brew_install --cask ghostty kitty
    else
        # Ghostty installation on Arch
        local aur_cmd=""; command_exists paru && aur_cmd="paru" || aur_cmd="yay"
        if $aur_cmd -Ss ghostty &>/dev/null; then
            aur_install ghostty || true
        else
            print_info "Ghostty not available in AUR, installing from official source..."
            # Install dependencies and build from source if needed
            aur_install gtk4 libadwaita || true
        fi
        aur_install kitty || true  # Fallback
    fi

    # Configure Ghostty (primary terminal)
    if [[ -f "$CONFIGS_DIR/ghostty.conf" ]]; then
        ensure_directory "$HOME/.config/ghostty"
        cp -f "$CONFIGS_DIR/ghostty.conf" "$HOME/.config/ghostty/config"
        print_success "Ghostty configured as default terminal"

        # Setup Ghostty drop-down terminal script on Linux
        if is_linux && [[ -f "$CONFIGS_DIR/scripts/ghostty-dropdown.sh" ]]; then
            ensure_directory "$HOME/.local/bin"
            cp -f "$CONFIGS_DIR/scripts/ghostty-dropdown.sh" "$HOME/.local/bin/ghostty-dropdown"
            chmod +x "$HOME/.local/bin/ghostty-dropdown"
            print_success "Ghostty drop-down script installed"

            # Create desktop file for KDE shortcut
            if is_kde_plasma; then
                ensure_directory "$HOME/.local/share/applications"
                cat > "$HOME/.local/share/applications/ghostty-dropdown.desktop" << 'EOF'
[Desktop Entry]
Name=Ghostty Dropdown Terminal
Comment=Toggle drop-down terminal (Quake-style)
Exec=$HOME/.local/bin/ghostty-dropdown
Icon=utilities-terminal
Type=Application
Categories=Utility;TerminalEmulator;
NoDisplay=true
EOF
                # Fix the $HOME in Exec path
                sed -i "s|\$HOME|$HOME|g" "$HOME/.local/share/applications/ghostty-dropdown.desktop"
                update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

                # Configure F12 shortcut
                local kwrite_cmd="kwriteconfig5"
                command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"
                "$kwrite_cmd" --file kglobalshortcutsrc --group ghostty-dropdown.desktop --key _launch "F12,F12,Ghostty Dropdown Terminal"

                print_success "Ghostty dropdown shortcut configured (F12)"
            fi
        fi
    fi

    # Configure Kitty (fallback)
    if command_exists kitty && [[ -f "$CONFIGS_DIR/kitty.conf" ]]; then
        ensure_directory "$HOME/.config/kitty"
        cp -f "$CONFIGS_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        [[ -f "$CONFIGS_DIR/kitty-session.conf" ]] && cp -f "$CONFIGS_DIR/kitty-session.conf" "$HOME/.config/kitty/kitty-session.conf"
    fi

    # Install Nerd Fonts
    install_nerd_fonts

    # Install CLI tools
    if is_macos; then
        # Everything else on the command line comes from configs/mise/config.toml
        brew_install zsh eza btop procs xan mtr nmap bandwhich tree watch asciinema noti
    else
        # Split into groups so one failure doesn't block the rest
        # Everything else on the command line comes from configs/mise/config.toml
        aur_install zsh eza btop procs tree procps-ng || true
        aur_install mtr nmap asciinema xan bandwhich noti wmctrl xdotool || true
    fi

    # Configure Yazi
    if command_exists yazi && [[ -d "$CONFIGS_DIR/yazi" ]]; then
        ensure_directory "$HOME/.config/yazi"
        [[ -f "$CONFIGS_DIR/yazi/yazi.toml" ]] && cp -f "$CONFIGS_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
        [[ -f "$CONFIGS_DIR/yazi/keymap.toml" ]] && cp -f "$CONFIGS_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
        [[ -f "$CONFIGS_DIR/yazi/theme.toml" ]] && cp -f "$CONFIGS_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    fi

    # Set Zsh as default shell
    if command_exists zsh && [[ "$SHELL" != *"zsh"* ]]; then
        print_info "Setting Zsh as default shell"
        if is_macos; then
            chsh -s /bin/zsh || true
        else
            local zsh_path
            zsh_path=$(command -v zsh)
            # chsh refuses shells absent from /etc/shells; register first.
            if [[ -n "$zsh_path" ]] && ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
            fi
            chsh -s "$zsh_path" || true
        fi
    fi

    # Install zinit
    local ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if ! [[ -d "$ZINIT_HOME" ]]; then
        ensure_directory "$(dirname "$ZINIT_HOME")"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || true
    fi

    # Install shell configurations
    print_info "Installing shell configurations..."

    # Install zshrc (already contains mise activation)
    if [[ -f "$CONFIGS_DIR/zshrc" ]]; then
        cp -f "$CONFIGS_DIR/zshrc" "$HOME/.zshrc"
        print_success "Installed .zshrc"
    fi

    # Install aliases
    if [[ -f "$CONFIGS_DIR/aliases.sh" ]]; then
        ensure_directory "$HOME/.config/shell"
        cp -f "$CONFIGS_DIR/aliases.sh" "$HOME/.config/shell/aliases.sh"
        print_success "Installed aliases.sh"
    fi

    # Install project templates
    if [[ -f "$CONFIGS_DIR/project-templates.sh" ]]; then
        cp -f "$CONFIGS_DIR/project-templates.sh" "$HOME/.config/shell/project-templates.sh"
        chmod +x "$HOME/.config/shell/project-templates.sh"
        print_success "Installed project-templates.sh"
    fi

    # Install Starship prompt config
    if [[ -f "$CONFIGS_DIR/starship.toml" ]]; then
        ensure_directory "$HOME/.config"
        cp -f "$CONFIGS_DIR/starship.toml" "$HOME/.config/starship.toml"
        print_success "Installed starship.toml"
    fi

    # Install project template directory if exists
    if [[ -d "$CONFIGS_DIR/project-templates" ]]; then
        ensure_directory "$HOME/.config"
        cp -rf "$CONFIGS_DIR/project-templates" "$HOME/.config/project-templates"
        print_info "Project templates installed to ~/.config/project-templates"
    fi

    # Install tool configurations
    for tool in btop lazygit topgrade ripgrep; do
        if command_exists "$tool"; then
            case "$tool" in
                btop)
                    [[ -f "$CONFIGS_DIR/btop.conf" ]] && ensure_directory "$HOME/.config/btop" && cp -f "$CONFIGS_DIR/btop.conf" "$HOME/.config/btop/btop.conf"
                    ;;
                lazygit)
                    [[ -f "$CONFIGS_DIR/lazygit.yml" ]] && ensure_directory "$HOME/.config/lazygit" && cp -f "$CONFIGS_DIR/lazygit.yml" "$HOME/.config/lazygit/config.yml"
                    ;;
                topgrade)
                    [[ -f "$CONFIGS_DIR/topgrade.toml" ]] && ensure_directory "$HOME/.config/topgrade" && cp -f "$CONFIGS_DIR/topgrade.toml" "$HOME/.config/topgrade/topgrade.toml"
                    ;;
                ripgrep)
                    [[ -f "$CONFIGS_DIR/ripgreprc" ]] && cp -f "$CONFIGS_DIR/ripgreprc" "$HOME/.ripgreprc"
                    ;;
            esac
        fi
    done

    # Install vivid theme
    if command_exists vivid && [[ -f "$CONFIGS_DIR/tokyonight-storm.yml" ]]; then
        ensure_directory "$HOME/.config/vivid/themes"
        cp -f "$CONFIGS_DIR/tokyonight-storm.yml" "$HOME/.config/vivid/themes/tokyonight-storm.yml"
    fi

    # .zshrc caches tool init scripts keyed on each binary; the vivid output
    # also depends on the theme above, so make the next shell rebuild them
    rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/*.key

    # Configure herdr
    if command_exists herdr && [[ -f "$CONFIGS_DIR/herdr/config.toml" ]]; then
        ensure_directory "$HOME/.config/herdr"
        cp -f "$CONFIGS_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
    fi

    # Install Tokyo Night themes for installed tools
    install_tokyo_night_themes

    # Set Ghostty as default terminal
    set_default_terminal

    # Setup Rofi launcher (Linux only)
    setup_rofi

    print_success "Terminal and shell setup complete"
}

setup_rofi() {
    # Rofi is Linux-only
    if is_macos; then
        return 0
    fi

    print_info "Setting up Rofi launcher..."

    # Install rofi and dependencies (rofi now has native Wayland support)
    aur_install rofi-wayland papirus-icon-theme || \
    aur_install rofi papirus-icon-theme || true

    # Install Wayland screenshot/clipboard tools
    aur_install grim slurp wl-clipboard cliphist || true

    # Copy rofi configuration
    if [[ -d "$CONFIGS_DIR/rofi" ]]; then
        ensure_directory "$HOME/.config/rofi"
        ensure_directory "$HOME/.config/rofi/scripts"

        cp -f "$CONFIGS_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

        # Copy and make scripts executable
        if [[ -d "$CONFIGS_DIR/rofi/scripts" ]]; then
            cp -f "$CONFIGS_DIR/rofi/scripts/"*.sh "$HOME/.config/rofi/scripts/" 2>/dev/null || true
            chmod +x "$HOME/.config/rofi/scripts/"*.sh 2>/dev/null || true
        fi

        print_success "Rofi configuration installed"
    fi

    # Setup cliphist to run with Wayland session
    if command_exists cliphist; then
        ensure_directory "$HOME/.config/systemd/user"

        # Create cliphist service for clipboard history
        cat > "$HOME/.config/systemd/user/cliphist.service" << 'EOF'
[Unit]
Description=Clipboard history service
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/wl-paste --watch cliphist store
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

        # Enable cliphist service
        systemctl --user daemon-reload
        systemctl --user enable --now cliphist.service 2>/dev/null || true
        print_success "Clipboard history service enabled"
    fi
}

set_default_terminal() {
    print_info "Setting Ghostty as default terminal..."

    if is_macos; then
        # macOS: Set default terminal via Launch Services
        # Ghostty registers itself, but we can set it as default handler
        if [[ -d "/Applications/Ghostty.app" ]] && ! defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -q 'com.mitchellh.ghostty'; then
            # Set Ghostty as default terminal emulator
            defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                '{LSHandlerContentType = "public.unix-executable"; LSHandlerRoleAll = "com.mitchellh.ghostty";}' 2>/dev/null || true
            print_success "Ghostty set as default terminal on macOS"
        fi
    elif is_kde_plasma; then
        # KDE Plasma: Set default terminal via kwriteconfig
        local kwrite_cmd="kwriteconfig5"
        command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

        if command_exists "$kwrite_cmd"; then
            "$kwrite_cmd" --file kdeglobals --group General --key TerminalApplication ghostty
            "$kwrite_cmd" --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
            print_success "Ghostty set as default terminal on KDE Plasma"
        fi

        # Also set via xdg-mime for other apps
        if command_exists xdg-mime; then
            xdg-mime default com.mitchellh.ghostty.desktop x-scheme-handler/terminal 2>/dev/null || true
        fi

        # update-alternatives is Debian-only, skip on Arch
    fi
}
