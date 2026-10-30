# shellcheck shell=bash
# Sourced by install.sh.

setup_dotfiles() {
    print_header "Dotfiles"

    install_links

    # .zshrc caches tool init scripts keyed on each binary; the vivid output
    # also depends on the theme, so make the next shell rebuild them
    rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/*.key

    print_success "Dotfiles linked from $CONFIGS_DIR"
}
