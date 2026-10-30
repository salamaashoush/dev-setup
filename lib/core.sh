# shellcheck shell=bash
# Sourced by install.sh.

FAILED_PACKAGES=()

cleanup() {
    local exit_code=$?
    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠${NC} These did not install: ${FAILED_PACKAGES[*]}"
    fi
    if [[ $exit_code -ne 0 && "${INSTALLING:-false}" == true ]]; then
        echo -e "${RED}✗ Installation failed with exit code $exit_code${NC}"
        [[ -f "$INSTALL_LOG" ]] && echo "Log: $INSTALL_LOG"
        echo "To retry, run: $0"
    fi
}

error_handler() {
    local line_no=$1 error_code=$2 file=$3
    echo -e "${RED}✗ $file:$line_no exited with $error_code${NC}"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_step() {
    echo -e "${PURPLE}→${NC} $1"
}

is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

is_arch_linux() {
    is_linux && [[ -f /etc/arch-release ]]
}

is_endeavouros() {
    is_arch_linux && [[ -f /etc/endeavouros-release ]]
}

is_cachyos() {
    is_arch_linux || return 1
    # /etc/cachyos-release is absent on current releases; ID= in os-release is authoritative
    [[ -f /etc/cachyos-release ]] && return 0
    grep -q '^ID=cachyos' /etc/os-release 2>/dev/null && return 0
    pacman -Q cachyos-settings &>/dev/null
}

has_nvidia_gpu() {
    is_linux && lspci -nn 2>/dev/null | grep -qiE 'vga|3d controller' && \
        lspci -nn 2>/dev/null | grep -iE 'vga|3d controller' | grep -qi nvidia
}

has_amd_gpu() {
    is_linux && lspci -nn 2>/dev/null | grep -iE 'vga|3d controller' | grep -qiE 'amd/ati|advanced micro devices'
}

has_intel_gpu() {
    is_linux && lspci -nn 2>/dev/null | grep -iE 'vga|3d controller' | grep -qi intel
}

# Blackwell (RTX 50 / GB2xx) has no proprietary kernel module — open modules are mandatory.
nvidia_requires_open_modules() {
    has_nvidia_gpu || return 1
    lspci -nn 2>/dev/null | grep -iE 'vga|3d controller' | grep -qiE 'GB2[0-9]{2}|RTX 50'
}

# Ryzen X3D parts with the asymmetric-CCD driver expose a cache/frequency mode switch
has_amd_x3d_switch() {
    compgen -G '/sys/bus/platform/drivers/amd_x3d_vcache/*/amd_x3d_mode' > /dev/null 2>&1
}

has_sched_ext() {
    [[ -d /sys/kernel/sched_ext ]]
}

is_kde_plasma() {
    is_linux && (command -v plasmashell &> /dev/null || [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || [[ "$DESKTOP_SESSION" == "plasma" ]])
}

get_platform() {
    if is_macos; then
        echo "macos"
    elif is_arch_linux; then
        echo "arch"
    elif is_linux; then
        echo "linux"
    else
        echo "unknown"
    fi
}

get_macos_version() {
    if is_macos; then
        sw_vers -productVersion 2>/dev/null || echo "Unknown"
    else
        echo "N/A"
    fi
}

command_exists() {
    command -v "$1" &> /dev/null
}

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

BACKUP_DIR="$HOME/.dev-setup-backup/$(date +%Y%m%d_%H%M%S)"

# The backup mirrors the path under $HOME, so ghostty/config and bat/config
# cannot overwrite each other.
backup_file() {
    local file="$1"
    [[ -e "$file" || -L "$file" ]] || return 0
    local rel="${file#"$HOME"/}"
    ensure_directory "$BACKUP_DIR/$(dirname "$rel")"
    cp -RP "$file" "$BACKUP_DIR/$rel"
    print_info "Backed up $file to $BACKUP_DIR"
}

aur_install() {
    # Wrapper: uses paru if available, falls back to yay
    local aur_cmd=""
    if command_exists paru; then
        aur_cmd="paru"
    elif command_exists yay; then
        aur_cmd="yay"
    else
        print_error "No AUR helper found (paru or yay). Skipping: $*"
        FAILED_PACKAGES+=("$@")
        return 1
    fi
    "$aur_cmd" -S --needed --noconfirm "$@" && return 0

    # As with brew_install: retry alone so one bad name does not sink the batch
    local pkg failed=0
    for pkg in "$@"; do
        pacman -Q "$pkg" &>/dev/null && continue
        "$aur_cmd" -S --needed --noconfirm "$pkg" || { FAILED_PACKAGES+=("$pkg"); failed=1; }
    done
    return "$failed"
}

# One renamed, removed, or disabled name makes Homebrew reject the whole batch,
# so on failure retry each package alone and record what still fails.
brew_install() {
    local kind=()
    if [[ "${1:-}" == "--cask" ]]; then
        kind=(--cask)
        shift
    fi
    brew install "${kind[@]}" "$@" && return 0

    local pkg
    for pkg in "$@"; do
        brew list "${kind[@]}" "$pkg" &>/dev/null && continue
        brew install "${kind[@]}" "$pkg" || FAILED_PACKAGES+=("$pkg")
    done
    return 0
}

# Apple Silicon and Intel Macs use different Homebrew prefixes
load_brew_env() {
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            eval "$("$candidate" shellenv)"
            return 0
        fi
    done
    return 1
}

# Ask for the password once, then refresh the timestamp so long downloads do not
# leave a later step waiting at a sudo prompt.
keep_sudo_alive() {
    sudo -v || { print_error "sudo access is required"; exit 1; }
    while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
}

download_file() {
    local url="$1"
    local dest="$2"
    local max_retries="${3:-3}"

    for ((i=1; i<=max_retries; i++)); do
        if curl -fsSL "$url" -o "$dest"; then
            return 0
        else
            print_warning "Download attempt $i/$max_retries failed"
            sleep 2
        fi
    done

    print_error "Failed to download $url after $max_retries attempts"
    return 1
}
