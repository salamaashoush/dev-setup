# shellcheck shell=bash
# Sourced by install.sh.

verify_installation() {
    print_header "Verifying Installation"

    local errors=0
    local warnings=0

    # Check essential tools
    local essential_tools=(
        "git:Git version control"
        "zsh:Zsh shell"
        "nvim:Neovim editor"
        "fzf:Fuzzy finder"
        "rg:Ripgrep search"
        "fd:fd file finder"
        "bat:Bat cat replacement"
        "eza:Eza ls replacement"
        "zoxide:Zoxide smart cd"
        "starship:Starship prompt"
        "mise:mise tool manager"
        "herdr:herdr agent multiplexer"
    )

    print_info "Checking essential tools..."
    for tool_entry in "${essential_tools[@]}"; do
        local tool="${tool_entry%%:*}"
        local desc="${tool_entry#*:}"
        if command_exists "$tool"; then
            print_success "$desc ($tool)"
        else
            print_error "$desc ($tool) - NOT FOUND"
            errors=$((errors + 1))
        fi
    done

    # Check development tools
    local dev_tools=(
        "node:Node.js"
        "bun:Bun runtime"
        "rustc:Rust compiler"
        "cargo:Cargo package manager"
        "pnpm:pnpm"
        "gh:GitHub CLI"
        "claude:Claude Code"
        "docker:Docker"
    )

    echo ""
    print_info "Checking development tools..."
    for tool_entry in "${dev_tools[@]}"; do
        local tool="${tool_entry%%:*}"
        local desc="${tool_entry#*:}"
        if command_exists "$tool"; then
            local version
            version=$($tool --version 2>/dev/null | head -1 || echo "installed")
            print_success "$desc: $version"
        else
            print_warning "$desc ($tool) - not installed"
            warnings=$((warnings + 1))
        fi
    done

    # Check Nerd Fonts
    echo ""
    verify_nerd_fonts

    # Check shell config
    echo ""
    print_info "Checking configurations..."
    [[ -f "$HOME/.zshrc" ]] && print_success "$HOME/.zshrc exists" || { print_error "$HOME/.zshrc missing"; errors=$((errors + 1)); }
    [[ -f "$HOME/.gitconfig" ]] && print_success "$HOME/.gitconfig exists" || { print_error "$HOME/.gitconfig missing"; errors=$((errors + 1)); }
    [[ -f "$HOME/.config/starship.toml" ]] && print_success "starship.toml exists" || { print_warning "starship.toml missing"; warnings=$((warnings + 1)); }
    [[ -d "$HOME/.config/ghostty" ]] && print_success "Ghostty config exists" || { print_warning "Ghostty config missing"; warnings=$((warnings + 1)); }

    # Check SSH key
    echo ""
    print_info "Checking SSH setup..."
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        print_success "SSH key exists"
        print_info "Public key fingerprint: $(ssh-keygen -lf "$HOME/.ssh/id_ed25519.pub" 2>/dev/null | awk '{print $2}')"
    else
        print_warning "SSH key not found"
        warnings=$((warnings + 1))
    fi

    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        echo ""
        print_warning "${#FAILED_PACKAGES[@]} package(s) failed to install; they are listed at the end"
        warnings=$((warnings + ${#FAILED_PACKAGES[@]}))
    fi

    # Summary
    echo ""
    print_header "Verification Summary"
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        print_success "All checks passed! Your environment is ready."
    elif [[ $errors -eq 0 ]]; then
        print_success "Installation complete with $warnings warning(s)"
    else
        print_error "Installation has $errors error(s) and $warnings warning(s)"
        print_info "Run the script again or install missing components manually"
    fi
}

# Read-only: compares this machine with the repo and changes nothing.
run_doctor() {
    print_header "Doctor"
    local problems=0

    print_info "Dotfiles (configs/links.txt)"
    if check_links; then
        print_success "Every link points into $CONFIGS_DIR"
    else
        problems=$((problems + 1))
    fi

    print_info "Git"
    if git config --global --get-all include.path 2>/dev/null | grep -qxF "$CONFIGS_DIR/gitconfig"; then
        print_success "~/.gitconfig includes configs/gitconfig"
    else
        print_warning "~/.gitconfig does not include $CONFIGS_DIR/gitconfig (run --only git)"
        problems=$((problems + 1))
    fi

    print_info "mise"
    if ! command_exists mise; then
        print_warning "mise is not installed"
        problems=$((problems + 1))
    elif [[ "$(readlink "$HOME/.config/mise/config.toml")" != "$CONFIGS_DIR/mise/config.toml" ]]; then
        print_warning "~/.config/mise/config.toml is not a link to configs/mise/config.toml (run --only mise)"
        problems=$((problems + 1))
    elif ! (cd "$HOME" && mise doctor >/dev/null 2>&1); then
        print_warning "mise doctor reports problems; run it for details"
        problems=$((problems + 1))
    else
        print_success "mise config linked and mise doctor is clean"
    fi

    print_info "Tools"
    local tool
    for tool in git zsh nvim fzf rg fd bat eza zoxide starship mise herdr cargo node claude; do
        if ! command_exists "$tool"; then
            print_warning "$tool is not on PATH"
            problems=$((problems + 1))
        fi
    done
    if [[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config" ]]; then
        print_warning "ripgrep config is missing"
        problems=$((problems + 1))
    fi

    if is_macos; then
        print_info "Builds run faster once your terminal is a Developer Tool:"
        print_info "  System Settings > Privacy & Security > Developer Tools, add the terminal"
    fi

    echo ""
    if [[ $problems -eq 0 ]]; then
        print_success "No drift found"
    else
        print_warning "$problems problem(s) found"
    fi
    [[ $problems -eq 0 ]]
}
