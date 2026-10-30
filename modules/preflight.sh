# shellcheck shell=bash
# Sourced by install.sh.

preflight_checks() {
    print_header "Pre-flight Checks"

    # Check internet connectivity
    print_step "Checking internet connectivity..."
    if ! curl -fsSL --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_error "No internet connection. Please connect to the internet and try again."
        exit 1
    fi
    print_success "Internet connection available"

    # Check available disk space (require at least 10GB free)
    print_step "Checking available disk space..."
    local min_space_gb=10
    local available_space_kb
    if is_macos; then
        available_space_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    else
        available_space_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    fi
    local available_space_gb=$((available_space_kb / 1024 / 1024))

    if [[ $available_space_gb -lt $min_space_gb ]]; then
        print_error "Insufficient disk space. Need at least ${min_space_gb}GB free, have ${available_space_gb}GB."
        exit 1
    fi
    print_success "Disk space OK (${available_space_gb}GB available)"

    # Platform-specific checks
    if is_macos; then
        # Check for Xcode Command Line Tools (macOS only)
        if ! xcode-select -p &>/dev/null; then
            print_warning "Installing Xcode Command Line Tools..."
            xcode-select --install
            print_info "Please complete the installation and run this script again"
            exit 0
        else
            print_success "Xcode Command Line Tools installed"
        fi

        # Install Homebrew if missing
        if ! load_brew_env; then
            print_info "Installing Homebrew..."
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            load_brew_env || { print_error "Homebrew installation failed"; exit 1; }
        fi
        print_success "Homebrew $(brew --version | head -1 | awk '{print $2}') at $(brew --prefix)"

        # Colima's config enables Rosetta for x86_64 containers, and some casks
        # still ship Intel-only binaries
        if [[ "$(uname -m)" == "arm64" ]] && ! arch -x86_64 /usr/bin/true &>/dev/null; then
            print_info "Installing Rosetta 2..."
            sudo softwareupdate --install-rosetta --agree-to-license || print_warning "Rosetta installation failed"
        fi
    elif is_arch_linux; then
        # Check for essential Arch Linux tools
        if ! command_exists pacman; then
            print_error "This system doesn't appear to be Arch Linux (pacman not found)"
            exit 1
        fi

        # Update system (prompt user first — unattended upgrades can break Arch/CachyOS)
        print_warning "System upgrade recommended before installing packages."
        local upgrade=""
        ask_yes_no upgrade "Run 'sudo pacman -Syu' now?" true
        if [[ "$upgrade" == true ]]; then
            if can_ask; then
                sudo pacman -Syu
            else
                sudo pacman -Syu --noconfirm
            fi
        fi

        # Install AUR helper if missing (prefer paru on CachyOS, yay otherwise)
        if ! command_exists paru && ! command_exists yay; then
            print_info "Installing AUR helper..."
            sudo pacman -S --needed --noconfirm git base-devel
            if is_cachyos; then
                sudo pacman -S --needed --noconfirm paru || {
                    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru
                    cd /tmp/paru && makepkg -si --noconfirm
                    cd - && rm -rf /tmp/paru
                }
            else
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay && makepkg -si --noconfirm
                cd - && rm -rf /tmp/yay
            fi
        fi
    fi

    # setup_git may reset ~/.gitconfig; linked dotfiles back themselves up
    [[ -f "$HOME/.gitconfig" ]] && backup_file "$HOME/.gitconfig"
    return 0
}
