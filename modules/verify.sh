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
        print_warning "Packages that failed to install:"
        local pkg
        for pkg in "${FAILED_PACKAGES[@]}"; do
            print_warning "  $pkg"
        done
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
