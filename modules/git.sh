# shellcheck shell=bash
# Sourced by install.sh.

setup_ssh_key() {
    local ssh_key="$HOME/.ssh/id_ed25519"
    if [[ ! -f "$ssh_key" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        if can_ask; then
            print_info "You can set a passphrase for extra security (press Enter for none)"
            ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$ssh_key"
        else
            ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$ssh_key" -N ""
        fi
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

    # Configure Git
    if command_exists git; then
        # ~/.gitconfig belongs to this machine: identity, credential helpers and
        # whatever `git config --global` writes later. The shared settings come
        # from the repo through include.path, so none of that lands in it.
        local shared="$CONFIGS_DIR/gitconfig"
        if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$shared"; then
            # Older runs rendered the whole template here
            backup_file "$HOME/.gitconfig"
            : > "$HOME/.gitconfig"
            git config --global --add include.path "$shared"
        fi
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"

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

        # What `gh auth setup-git` writes, except it records gh's versioned
        # install path, which breaks once mise prunes that version
        if command_exists gh; then
            local host
            for host in github.com gist.github.com; do
                git config --global --unset-all "credential.https://$host.helper" 2>/dev/null || true
                git config --global --add "credential.https://$host.helper" ''
                git config --global --add "credential.https://$host.helper" '!gh auth git-credential'
            done
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

    # Its own file: the system step rewrites wayland.conf on every run
    ensure_directory "$HOME/.config/environment.d"
    echo 'SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"' > "$HOME/.config/environment.d/ssh-agent.conf"

    # Containers and SSH-only sessions have no user systemd instance
    if ! systemctl --user show-environment &>/dev/null; then
        print_warning "No systemd user session; the SSH agent starts at the next graphical login"
        return 0
    fi
    systemctl --user daemon-reload
    systemctl --user enable ssh-agent.service
    systemctl --user start ssh-agent.service 2>/dev/null || true

    print_success "SSH agent configured to start automatically"
}
