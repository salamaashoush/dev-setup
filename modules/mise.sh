# shellcheck shell=bash
# Sourced by install.sh.

setup_mise() {
    print_header "Setting up Mise (Universal Version Manager)"

    # Install mise
    if ! command_exists mise && [[ ! -f "$HOME/.local/bin/mise" ]]; then
        print_info "Installing mise..."
        curl -fsSL https://mise.run | sh
    else
        print_success "Mise already installed"
    fi

    # Later steps configure tools mise installs, so they must resolve during this run
    export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

    # Determine mise executable path
    local mise_cmd=""
    if [[ -f "$HOME/.local/bin/mise" ]]; then
        mise_cmd="$HOME/.local/bin/mise"
    elif command_exists mise; then
        mise_cmd="mise"
    else
        print_error "Mise installation failed"
        return 1
    fi

    # The global config is a symlink into this repo, so `mise use -g` edits the
    # versioned file. A config.toml that is a real file predates the symlink and
    # holds this machine's own tools; it becomes conf.d/local.toml, which mise
    # also loads.
    local mise_dir="$HOME/.config/mise"
    local mise_local="$mise_dir/conf.d/local.toml"
    ensure_directory "$mise_dir/conf.d"
    if [[ -f "$mise_dir/config.toml" && ! -L "$mise_dir/config.toml" ]]; then
        if [[ -e "$mise_local" ]]; then
            mv "$mise_local" "$mise_local.bak-$(date +%Y%m%d%H%M%S)"
        fi
        mv "$mise_dir/config.toml" "$mise_local"
        print_info "Moved your own mise tools to $mise_local"
    fi
    rm -f "$mise_dir/conf.d/dev-setup.toml"
    ln -sfn "$CONFIGS_DIR/mise/config.toml" "$mise_dir/config.toml"
    # mise reads and updates a lockfile that exists, so every machine installs
    # the same versions with checksums; `mise up` moves it forward
    link_config mise/mise.lock "$mise_dir/mise.lock"


    "$mise_cmd" install gh || true
    use_github_token

    print_info "Installing runtimes, CLI tools, and Claude Code with mise..."
    if ! "$mise_cmd" install; then
        # mise installs every tool it can before failing, so only the ones it named above are missing
        print_warning "Some mise tools failed to install; re-run 'mise install' to retry them"
        FAILED_PACKAGES+=("mise install (see errors above)")
    fi

    # Omarchy ships herdr as a system package; a mise copy earlier on PATH would
    # shadow it with a client that may not speak the packaged server's protocol.
    if ! command_exists herdr; then
        "$mise_cmd" use --path "$mise_local" herdr@latest || FAILED_PACKAGES+=("mise:herdr")
    fi

    print_success "Mise setup complete"
}

# A gh that is already signed in (bootstrap.sh signs in when it had to clone a
# private copy) lends its token to mise, lifting the anonymous GitHub API limit
# of 60 requests an hour that its release lookups would otherwise run into.
use_github_token() {
    command_exists gh && gh auth status &>/dev/null || return 0
    GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}"
    export GITHUB_TOKEN
}
