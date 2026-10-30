# shellcheck shell=bash
# Sourced by install.sh.

BREWFILE="$SCRIPT_DIR/Brewfile"
ARCH_PACKAGES="$SCRIPT_DIR/packages/arch.txt"

arch_package_list() {
    sed -e 's/#.*//' "$ARCH_PACKAGES" | tr -s '[:space:]' '\n' | sed '/^$/d'
}

setup_packages() {
    print_header "Packages"

    if is_macos; then
        INSTALL_GAMEDEV="$INSTALL_GAMEDEV" brew bundle install --no-upgrade --file "$BREWFILE" \
            || FAILED_PACKAGES+=("brew bundle (the log names which)")
    else
        local packages=()
        mapfile -t packages < <(arch_package_list)
        aur_install "${packages[@]}" || true
    fi

    print_success "Packages installed"
}

# Prints each listed package that is missing and returns non-zero if any are.
check_packages() {
    if is_macos; then
        HOMEBREW_NO_AUTO_UPDATE=1 INSTALL_GAMEDEV="$INSTALL_GAMEDEV" brew bundle check --no-upgrade --verbose --file "$BREWFILE"
        return
    fi
    local pkg missing=0
    while read -r pkg; do
        pacman -Q "$pkg" &>/dev/null || { print_warning "$pkg is not installed"; missing=1; }
    done < <(arch_package_list)
    return "$missing"
}
