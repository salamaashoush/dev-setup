# shellcheck shell=bash
# Sourced by install.sh.

setup_ssh_key() {
    local ssh_key="$HOME/.ssh/id_ed25519"
    if [[ ! -f "$ssh_key" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        print_info "You can set a passphrase for extra security (press Enter for none)"
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$ssh_key"
        chmod 600 "$ssh_key"
        chmod 644 "${ssh_key}.pub"
        print_info "SSH key generated. Public key:"
        cat "${ssh_key}.pub"
    fi

    # macOS: keep the passphrase in the login Keychain so it is asked once
    if is_macos; then
        local ssh_config="$HOME/.ssh/config"
        if ! grep -qs 'UseKeychain' "$ssh_config"; then
            # IgnoreUnknown keeps a non-Apple ssh (e.g. Homebrew openssh) from rejecting UseKeychain
            cat >> "$ssh_config" << 'SSHCONF'

Host *
  IgnoreUnknown UseKeychain
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
SSHCONF
            chmod 600 "$ssh_config"
        fi
        ssh-add --apple-use-keychain "$ssh_key" 2>/dev/null || true
    fi
}

setup_git() {
    print_header "Git Configuration"

    # Install git tools
    if is_macos; then
        brew_install git
    else
        aur_install git || true
    fi

    # Configure Git
    if command_exists git; then
        local git_name="$GIT_NAME"
        local git_email="$GIT_EMAIL"

        # Install gitconfig
        if [[ -f "$CONFIGS_DIR/gitconfig" ]]; then
            sed -e "s/{{USER_NAME}}/$git_name/g" \
                -e "s/{{USER_EMAIL}}/$git_email/g" \
                "$CONFIGS_DIR/gitconfig" > "$HOME/.gitconfig"
        fi

        # Install supporting files
        [[ -f "$CONFIGS_DIR/gitignore_global" ]] && cp -f "$CONFIGS_DIR/gitignore_global" "$HOME/.gitignore_global"
        [[ -f "$CONFIGS_DIR/gitmessage" ]] && cp -f "$CONFIGS_DIR/gitmessage" "$HOME/.gitmessage"

        # Configure GitUI
        if command_exists gitui; then
            ensure_directory "$HOME/.config/gitui"
            [[ -f "$CONFIGS_DIR/gitui/key_bindings.ron" ]] && cp -f "$CONFIGS_DIR/gitui/key_bindings.ron" "$HOME/.config/gitui/key_bindings.ron"
        fi

        # Install git helper scripts
        if [[ -f "$SCRIPT_DIR/scripts/git-clone-bare-for-worktrees.sh" ]]; then
            mkdir -p "$HOME/.local/bin"
            cp "$SCRIPT_DIR/scripts/git-clone-bare-for-worktrees.sh" "$HOME/.local/bin/git-clone-bare-for-worktrees"
            chmod +x "$HOME/.local/bin/git-clone-bare-for-worktrees"
        fi

        # Platform-specific credential helper
        if is_macos; then
            git config --global credential.helper osxkeychain
        elif is_linux; then
            git config --global credential.helper 'cache --timeout=3600'
        fi

        # The template replaced any helper `gh auth login` registered earlier
        if command_exists gh && gh auth status &>/dev/null; then
            gh auth setup-git || true
        fi

        # Setup SSH agent (Linux only - macOS uses keychain)
        if is_linux; then
            setup_ssh_agent
        fi
    fi

    print_success "Git configuration complete"
}

setup_ssh_agent() {
    print_info "Configuring SSH agent..."

    # Create systemd user service for SSH agent
    ensure_directory "$HOME/.config/systemd/user"

    cat > "$HOME/.config/systemd/user/ssh-agent.service" << 'EOF'
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK
ExecStartPost=/bin/sh -c 'ssh-add -q ~/.ssh/id_ed25519 2>/dev/null || true'

[Install]
WantedBy=default.target
EOF

    # Enable and start SSH agent
    systemctl --user daemon-reload
    systemctl --user enable ssh-agent.service
    systemctl --user start ssh-agent.service 2>/dev/null || true

    # Add SSH_AUTH_SOCK to environment
    if ! grep -q "SSH_AUTH_SOCK" "$HOME/.config/environment.d/wayland.conf" 2>/dev/null; then
        echo 'SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"' >> "$HOME/.config/environment.d/wayland.conf"
    fi

    print_success "SSH agent configured to start automatically"
}
