# shellcheck shell=bash
# Sourced by install.sh.

# configs/links.txt lists every dotfile as "mode os source target". A link
# makes the target a symlink into this repo, so editing either side is the same
# edit. A seed is copied once and then left alone, for apps that rewrite their
# own config file (btop writes every setting back on exit).
LINKS_FILE="$CONFIGS_DIR/links.txt"

link_config() {
    local src="$CONFIGS_DIR/$1" dest="$2"
    if [[ ! -e "$src" ]]; then
        print_error "Missing $src"
        FAILED_PACKAGES+=("link: $1")
        return 0
    fi
    [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]] && return 0
    if [[ -z "$dest" || "$dest" == "$HOME" || "$dest" == "/" ]]; then
        print_error "Refusing to replace '$dest' with a link to $src"
        FAILED_PACKAGES+=("link: $1")
        return 0
    fi
    ensure_directory "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        backup_file "$dest"
        rm -rf "$dest"
    fi
    ln -s "$src" "$dest"
}

seed_config() {
    local src="$CONFIGS_DIR/$1" dest="$2"
    [[ -e "$dest" ]] && return 0
    ensure_directory "$(dirname "$dest")"
    cp -R "$src" "$dest"
}

# Prints "mode source target" for each entry that applies here, ~ expanded.
links_for_platform() {
    local platform mode os src dest
    platform=$(is_macos && echo macos || echo linux)
    while read -r mode os src dest; do
        [[ -z "$mode" || "$mode" == \#* ]] && continue
        [[ "$os" == all || "$os" == "$platform" ]] || continue
        printf '%s %s %s\n' "$mode" "$src" "${dest/#\~/$HOME}"
    done < "$LINKS_FILE"
}

install_links() {
    local mode src dest
    while read -r mode src dest; do
        case "$mode" in
            link) link_config "$src" "$dest" ;;
            seed) seed_config "$src" "$dest" ;;
            *)
                print_error "Unknown mode '$mode' in $LINKS_FILE"
                FAILED_PACKAGES+=("links.txt: $mode")
                ;;
        esac
    done < <(links_for_platform)
}

# Prints each target that differs from links.txt and returns how many did.
check_links() {
    local mode src dest bad=0
    while read -r mode src dest; do
        if [[ "$mode" == link ]] && [[ ! -L "$dest" || "$(readlink "$dest")" != "$CONFIGS_DIR/$src" ]]; then
            print_warning "$dest is not a link to configs/$src"
            bad=$((bad + 1))
        elif [[ "$mode" == seed && ! -e "$dest" ]]; then
            print_warning "$dest is missing (seeded from configs/$src)"
            bad=$((bad + 1))
        fi
    done < <(links_for_platform)
    return "$bad"
}
