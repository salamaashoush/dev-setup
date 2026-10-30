# shellcheck shell=bash
# Sourced by install.sh.

# Homebrew's compose and buildx are CLI plugins outside Docker's default search
# path, so `docker compose` and `docker buildx` fail until the CLI is told where they are.
configure_docker_cli_plugins() {
    local cfg="$HOME/.docker/config.json"
    local plugin_dir
    plugin_dir="$(brew --prefix)/lib/docker/cli-plugins"
    ensure_directory "$HOME/.docker"

    if [[ ! -s "$cfg" ]]; then
        printf '{\n  "cliPluginsExtraDirs": ["%s"]\n}\n' "$plugin_dir" > "$cfg"
    elif command_exists jq; then
        local tmp
        tmp=$(mktemp)
        jq --arg dir "$plugin_dir" \
            '.cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) + [$dir] | unique)' \
            "$cfg" > "$tmp" && mv "$tmp" "$cfg"
    else
        print_warning "Add \"cliPluginsExtraDirs\": [\"$plugin_dir\"] to $cfg for docker compose/buildx"
        return 0
    fi
    print_success "Docker CLI plugins registered from $plugin_dir"
}

setup_docker_linux() {
    print_info "Configuring Docker for Linux..."

    # Create docker group if it doesn't exist
    if ! getent group docker &>/dev/null; then
        sudo groupadd docker
        print_success "Created docker group"
    fi

    # Add current user to docker group
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER"
        print_success "Added $USER to docker group"
        print_warning "You'll need to log out and back in for group changes to take effect"
        print_warning "Or run: newgrp docker"
    else
        print_info "User $USER is already in docker group"
    fi

    # Copy daemon.json configuration (backup existing first)
    if [[ -f "$CONFIGS_DIR/docker/daemon.json" ]]; then
        sudo mkdir -p /etc/docker
        if [[ -f /etc/docker/daemon.json ]]; then
            sudo cp /etc/docker/daemon.json "/etc/docker/daemon.json.bak.$(date +%Y%m%d_%H%M%S)"
            print_info "Backed up existing /etc/docker/daemon.json"
        fi
        sudo cp -f "$CONFIGS_DIR/docker/daemon.json" /etc/docker/daemon.json
        sudo chown root:root /etc/docker/daemon.json
        sudo chmod 644 /etc/docker/daemon.json
        print_success "Docker daemon configuration installed"
    fi

    # Enable and start Docker service
    sudo systemctl enable docker.socket
    sudo systemctl enable docker.service
    sudo systemctl start docker.socket
    sudo systemctl start docker.service

    # Wait for Docker to be ready
    print_info "Waiting for Docker to start..."
    local max_attempts=30
    local attempt=0
    while ! docker info &>/dev/null 2>&1; do
        sleep 1
        attempt=$((attempt + 1))
        if [[ $attempt -ge $max_attempts ]]; then
            break
        fi
    done

    if docker info &>/dev/null 2>&1; then
        print_success "Docker is running"
    else
        print_warning "Docker may not be fully started yet. Check with: systemctl status docker"
    fi

    # Create Docker config directory (BuildKit enabled by default in Docker 23+)
    if [[ ! -d "$HOME/.docker" ]]; then
        ensure_directory "$HOME/.docker"
    fi

    # Verify Docker installation
    verify_docker
}

verify_docker() {
    print_info "Verifying Docker installation..."

    local errors=0

    # Use sg to run docker commands with docker group permissions
    # This avoids needing to log out/in after adding user to docker group
    local docker_cmd="docker"
    if groups "$USER" 2>/dev/null | grep -q docker; then
        docker_cmd="sg docker -c docker"
    fi

    # Check Docker daemon
    if ! $docker_cmd info &>/dev/null 2>&1; then
        print_error "Docker daemon is not running"
        errors=$((errors + 1))
    else
        print_success "Docker daemon is running"
    fi

    # Check Docker Compose
    if $docker_cmd compose version &>/dev/null 2>&1; then
        local compose_version
        compose_version=$($docker_cmd compose version --short 2>/dev/null || echo "unknown")
        print_success "Docker Compose v$compose_version is available"
    else
        print_warning "Docker Compose plugin not available"
    fi

    # Check BuildKit
    if $docker_cmd buildx version &>/dev/null 2>&1; then
        print_success "Docker BuildKit is available"
    else
        print_warning "Docker BuildKit not available"
    fi

    # Test Docker by running hello-world
    if groups "$USER" 2>/dev/null | grep -q docker || [[ $EUID -eq 0 ]]; then
        print_info "Testing Docker with hello-world container..."
        if sg docker -c "docker run --rm hello-world" &>/dev/null 2>&1; then
            print_success "Docker test passed - containers work correctly"
            # Clean up
            sg docker -c "docker rmi hello-world" &>/dev/null 2>&1 || true
        else
            print_warning "Docker test failed - you may need to log out and back in"
            errors=$((errors + 1))
        fi
    else
        print_warning "Cannot test Docker - user not in docker group yet"
        print_info "Log out and back in, then run: docker run hello-world"
    fi

    # Show Docker info
    if [[ $errors -eq 0 ]]; then
        print_success "Docker is fully configured and working!"
    else
        print_warning "Docker setup completed with $errors warning(s)"
    fi

    # Print helpful commands
    echo ""
    print_info "Useful Docker commands:"
    print_info "  docker-start    - Start Docker service"
    print_info "  docker-stop     - Stop Docker service"
    print_info "  docker-status   - Check Docker status"
    print_info "  db-start postgres - Start PostgreSQL container"
    print_info "  db-start redis    - Start Redis container"
}

setup_rust_cargo_config() {
    is_linux || return 0
    command_exists mold || return 0

    local cfg="$HOME/.cargo/config.toml"
    local marker="# dev-setup: mold linker"

    if [[ -f "$cfg" ]] && grep -q "$marker" "$cfg"; then
        print_info "Cargo mold config already present"
        return 0
    fi

    if [[ -f "$cfg" ]]; then
        print_warning "$cfg exists — not modifying it automatically"
        print_info "To use mold, add:"
        print_info '  [target.x86_64-unknown-linux-gnu]'
        print_info '  rustflags = ["-C", "link-arg=-fuse-ld=mold"]'
        return 0
    fi

    ensure_directory "$HOME/.cargo"
    cat > "$cfg" << EOF
$marker
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=mold"]
EOF
    print_success "Cargo configured to link with mold"
}

setup_development_tools() {
    print_header "Development Tools Setup"

    # Where projects live; Bolt's repository search scans it
    ensure_directory "$HOME/Workspace"

    # Compilers and linkers. cmake, ninja, just, the JS and Rust toolchains, and
    # the cargo tools come from configs/mise/config.toml.
    if is_linux; then
        # mold: dramatically faster linking, which dominates Rust rebuild time
        aur_install base-devel gcc clang mold lld || true
    fi

    setup_rust_cargo_config

    # Code Editors
    if is_macos; then
        brew_install --cask zed
    else
        aur_install zed || true
        # Arch ships the CLI as zeditor; link `zed` so scripts, yazi and muscle memory agree
        if ! command_exists zed && command_exists zeditor; then
            ensure_directory "$HOME/.local/bin"
            ln -sf "$(command -v zeditor)" "$HOME/.local/bin/zed"
        fi
    fi

    # Configure Neovim (LazyVim). An existing config is left alone so a re-run
    # does not replace customisations with a fresh starter.
    if command_exists nvim && [[ ! -d "$HOME/.config/nvim" ]]; then
        if git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"; then
            [[ -f "$CONFIGS_DIR/lazyvim.json" ]] && cp -f "$CONFIGS_DIR/lazyvim.json" "$HOME/.config/nvim/lazyvim.json"
        fi
    fi


    # Container Tools
    if is_macos; then
        brew_install docker docker-buildx docker-compose colima
        configure_docker_cli_plugins

        # colima.yaml is seeded by links.txt. A running VM is left alone: stopping
        # it would kill every container to re-apply settings it already has.
        if command_exists colima && ! colima status &>/dev/null; then
            print_info "Starting Colima..."
            colima start || FAILED_PACKAGES+=("colima start")
        fi
    else
        # Install Docker and tools
        aur_install docker docker-buildx docker-compose || true

        # Setup Docker permissions and group
        setup_docker_linux
    fi

    # Dockside (https://github.com/salamaashoush/dockside), a desktop app for Docker,
    # Colima and Kubernetes. Its installer fetches the latest release into
    # /Applications on macOS or ~/.local/bin as an AppImage on Linux.
    print_info "Installing Dockside..."
    curl -fsSL https://raw.githubusercontent.com/salamaashoush/dockside/main/scripts/install.sh | bash \
        || FAILED_PACKAGES+=("dockside")

    # REMOVED: Database GUI tools - use web-based tools instead

    # API Tools for web development
    if is_macos; then
        brew_install --cask insomnia
    else
        aur_install insomnia-bin || true
    fi

    # Mise handles most version management now
    # Only keeping specialized toolchains

    # REMOVED: Haskell toolchain not needed for web/Rust dev

    # Claude Code comes from the mise config. This lets herdr resume its
    # sessions after a server restart.
    if command_exists herdr; then
        ensure_directory "$HOME/.claude"
        herdr integration install claude || print_warning "herdr Claude Code integration failed"
    fi

    setup_agent_kit

    print_success "Development tools setup complete"
}

# agent-kit (https://github.com/salamaashoush/agent-kit) carries Claude Code's
# global instructions, hooks and skills. It installs by symlink, so the clone in
# ~/Workspace is the live copy: an existing one is used as it is, never pulled.
setup_agent_kit() {
    [[ "$INSTALL_AGENT_KIT" == true ]] || return 0
    local dir="$HOME/Workspace/agent-kit"

    if [[ ! -d "$dir/.git" ]]; then
        git clone https://github.com/salamaashoush/agent-kit.git "$dir" || { FAILED_PACKAGES+=("agent-kit (clone)"); return 0; }
    fi

    # Its installer needs Python 3.11+, which python3 resolves to through the mise shims
    print_info "Installing agent-kit..."
    "$dir/install.sh" || FAILED_PACKAGES+=("agent-kit (install; re-run $dir/install.sh after signing in to claude)")
}
