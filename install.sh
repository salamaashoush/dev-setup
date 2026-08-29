#!/usr/bin/env bash
# Cross-Platform Developer Setup Script
# Supports macOS and Arch Linux (EndeavourOS, CachyOS)
#
# Usage: ./install.sh [--help]
#
# This script is designed to be:
# - Idempotent (safe to run multiple times)
# - Non-destructive (backs up existing configs)
# - Reversible (documents how to undo changes)

set -euo pipefail

# ==========================================
# Error Handling and Cleanup
# ==========================================

# Track if we're in the middle of a critical section
CRITICAL_SECTION=false
INSTALL_LOG=""

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        echo -e "\033[0;31m✗ Installation failed with exit code $exit_code\033[0m"
        if [[ -n "$INSTALL_LOG" && -f "$INSTALL_LOG" ]]; then
            echo "Check the log file for details: $INSTALL_LOG"
        fi
        echo ""
        echo "To retry, run: $0"
        echo "For help, run: $0 --help"
    fi
}

trap cleanup EXIT

error_handler() {
    local line_no=$1
    local error_code=$2
    echo ""
    echo -e "\033[0;31m✗ Error on line $line_no (exit code: $error_code)\033[0m"
    if [[ "$CRITICAL_SECTION" == "true" ]]; then
        echo "Error occurred during a critical section. System may be in an inconsistent state."
        echo "Please review the changes and run the script again."
    fi
}

trap 'error_handler ${LINENO} $?' ERR

# ==========================================
# Bash Version Check
# ==========================================

if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
    echo "Error: This script requires Bash 4.0 or higher."
    echo "Current version: $BASH_VERSION"
    if [[ -f /opt/homebrew/bin/bash ]] && [[ "$(/opt/homebrew/bin/bash --version | head -1 | cut -d' ' -f4 | cut -d'.' -f1)" -ge 4 ]]; then
        echo "Bash 4+ found at /opt/homebrew/bin/bash. Re-running with it..."
        exec /opt/homebrew/bin/bash "$0" "$@"
    else
        echo "Please install Bash 4+ (e.g., 'brew install bash' on macOS)"
        exit 1
    fi
fi

# ==========================================
# Script Configuration
# ==========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/configs" && pwd)}"
readonly CONFIGS_DIR="$CONFIG_DIR"  # Alias for compatibility
readonly SCRIPTS_DIR="${SCRIPTS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/scripts" && pwd)}"

# Create log file
INSTALL_LOG="$HOME/.dev-setup-install-$(date +%Y%m%d-%H%M%S).log"

# ==========================================
# Colors and Output Functions
# ==========================================

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

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

# ==========================================
# Platform Detection
# ==========================================

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

# ==========================================
# Utility Functions
# ==========================================

command_exists() {
    command -v "$1" &> /dev/null
}

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup_dir="$HOME/.dev-setup-backup/$(date +%Y%m%d_%H%M%S)"
        ensure_directory "$backup_dir"
        cp -r "$file" "$backup_dir/$(basename "$file")"
        print_info "Backed up $file"
    fi
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
        return 1
    fi
    "$aur_cmd" -S --needed --noconfirm "$@"
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

# ==========================================
# Pre-flight Checks
# ==========================================

preflight_checks() {
    print_header "Pre-flight Checks"

    # Check internet connectivity
    print_step "Checking internet connectivity..."
    if ! curl -fsSL --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_error "No internet connection. Please connect to the internet and try again."
        exit 1
    fi
    print_success "Internet connection available"

    # Check available disk space (require at least 10GB free)
    print_step "Checking available disk space..."
    local min_space_gb=10
    local available_space_kb
    if is_macos; then
        available_space_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    else
        available_space_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    fi
    local available_space_gb=$((available_space_kb / 1024 / 1024))

    if [[ $available_space_gb -lt $min_space_gb ]]; then
        print_error "Insufficient disk space. Need at least ${min_space_gb}GB free, have ${available_space_gb}GB."
        exit 1
    fi
    print_success "Disk space OK (${available_space_gb}GB available)"

    # Platform-specific checks
    if is_macos; then
        # Check for Xcode Command Line Tools (macOS only)
        if ! xcode-select -p &>/dev/null; then
            print_warning "Installing Xcode Command Line Tools..."
            xcode-select --install
            print_info "Please complete the installation and run this script again"
            exit 0
        else
            print_success "Xcode Command Line Tools installed"
        fi

        # Install Homebrew if missing
        if ! command_exists brew; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    elif is_arch_linux; then
        # Check for essential Arch Linux tools
        if ! command_exists pacman; then
            print_error "This system doesn't appear to be Arch Linux (pacman not found)"
            exit 1
        fi

        # Update system (prompt user first — unattended upgrades can break Arch/CachyOS)
        print_warning "System upgrade recommended before installing packages."
        read -p "Run 'sudo pacman -Syu' now? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            sudo pacman -Syu
        fi

        # Install AUR helper if missing (prefer paru on CachyOS, yay otherwise)
        if ! command_exists paru && ! command_exists yay; then
            print_info "Installing AUR helper..."
            sudo pacman -S --needed --noconfirm git base-devel
            if is_cachyos; then
                sudo pacman -S --needed --noconfirm paru || {
                    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru
                    cd /tmp/paru && makepkg -si --noconfirm
                    cd - && rm -rf /tmp/paru
                }
            else
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay && makepkg -si --noconfirm
                cd - && rm -rf /tmp/yay
            fi
        fi
    fi

    # Backup existing configs
    if [[ -f "$HOME/.zshrc" ]]; then
        print_info "Backing up existing configs..."
        [[ -f "$HOME/.zshrc" ]] && backup_file "$HOME/.zshrc"
        [[ -f "$HOME/.gitconfig" ]] && backup_file "$HOME/.gitconfig"
        [[ -f "$HOME/.config/kitty/kitty.conf" ]] && backup_file "$HOME/.config/kitty/kitty.conf"
    fi
}

# ==========================================
# System Optimizations
# ==========================================

setup_system_optimizations() {
    print_header "System Optimizations"

    if is_macos; then
        setup_macos_optimizations
    elif is_arch_linux; then
        setup_arch_linux_optimizations
    fi
}

setup_macos_optimizations() {
    print_info "Applying macOS optimizations (safe, reversible settings)..."

    # All settings below are safe and can be reverted by:
    # defaults delete <domain> <key>

    # ---- Dock Settings (visual only, safe) ----
    # Faster dock auto-hide animation (default is ~0.7)
    defaults write com.apple.dock autohide-time-modifier -float 0.5 2>/dev/null || true
    # Faster Mission Control animation
    defaults write com.apple.dock expose-animation-duration -float 0.5 2>/dev/null || true

    # ---- Keyboard Settings (safe, common preferences) ----
    # Faster key repeat (6 = fast, default is usually higher)
    defaults write NSGlobalDomain KeyRepeat -int 6 2>/dev/null || true
    # Shorter delay before key repeat starts (25 = quick, default is ~35)
    defaults write NSGlobalDomain InitialKeyRepeat -int 25 2>/dev/null || true

    # ---- Finder Settings (visual/UX, safe) ----
    # Show path bar at bottom of Finder
    defaults write com.apple.finder ShowPathbar -bool true 2>/dev/null || true
    # Show status bar at bottom of Finder
    defaults write com.apple.finder ShowStatusBar -bool true 2>/dev/null || true
    # Don't warn when changing file extensions
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false 2>/dev/null || true
    # Show hidden files (useful for developers)
    defaults write com.apple.finder AppleShowAllFiles -bool true 2>/dev/null || true

    # ---- Screenshot Settings (safe) ----
    # Save screenshots to dedicated folder
    ensure_directory "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots" 2>/dev/null || true
    # Disable shadow in screenshots (cleaner look)
    defaults write com.apple.screencapture disable-shadow -bool true 2>/dev/null || true
    # Use PNG format (high quality)
    defaults write com.apple.screencapture type png 2>/dev/null || true

    # ---- Safari Developer Settings (if Safari is used) ----
    # Enable Safari developer menu
    defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null || true

    # ---- Help Viewer (minor, safe) ----
    # Help viewer windows non-floating
    defaults write com.apple.helpviewer DevMode -bool true 2>/dev/null || true

    # ---- Apply changes by restarting affected apps ----
    print_info "Restarting Dock and Finder to apply changes..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true

    # Note: We intentionally do NOT disable:
    # - SIP (System Integrity Protection)
    # - Gatekeeper
    # - Power management aggressively
    # - Any system security features

    print_success "macOS optimizations applied (all changes are reversible)"
    print_info "To revert any setting: defaults delete <domain> <key>"
}

setup_arch_linux_optimizations() {
    print_info "Applying Arch Linux optimizations..."

    # Performance optimizations — skip on CachyOS (it ships its own tuned settings)
    if is_cachyos; then
        print_info "CachyOS detected — skipping sysctl/udev tuning (already optimized by cachyos-settings)"
    else
        if [[ ! -f /etc/sysctl.d/99-dev-setup-performance.conf ]]; then
            sudo tee /etc/sysctl.d/99-dev-setup-performance.conf > /dev/null << 'EOF'
# Dev-setup performance optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
            print_success "Performance sysctl settings applied"
        else
            print_info "Performance sysctl settings already configured"
        fi

        # IO scheduler (idempotent)
        if [[ ! -f /etc/udev/rules.d/60-ioschedulers.rules ]]; then
            echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null
            print_success "IO scheduler rule applied"
        else
            print_info "IO scheduler rule already configured"
        fi

        # Network optimizations (idempotent - only create if not exists)
        if [[ ! -f /etc/sysctl.d/99-dev-setup-network.conf ]]; then
            sudo tee /etc/sysctl.d/99-dev-setup-network.conf > /dev/null << 'EOF'
# Dev-setup network optimizations
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF
            print_success "Network sysctl settings applied"
        else
            print_info "Network sysctl settings already configured"
        fi
    fi

    # Graphics and audio — skip zram-generator on CachyOS (already configured)
    if is_cachyos; then
        aur_install cpupower libva-utils || true
    else
        aur_install cpupower zram-generator libva-utils || true
    fi

    # Audio setup with PipeWire (important for Plasma 6)
    aur_install pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber gst-plugin-pipewire lib32-pipewire lib32-pipewire-jack || true
    systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service || true

    # GPU drivers. These are independent checks, not a chain — hybrid systems
    # (discrete NVIDIA + AMD/Intel iGPU) need drivers for BOTH.
    if has_nvidia_gpu; then
        print_info "NVIDIA GPU detected"

        if nvidia_requires_open_modules; then
            print_info "Blackwell-class GPU (RTX 50 / GB2xx) — open kernel modules are mandatory"
            if pacman -Qq nvidia-dkms &>/dev/null || pacman -Qq nvidia &>/dev/null; then
                print_warning "Proprietary nvidia modules are installed but do not support this GPU."
                print_warning "Replace with nvidia-open-dkms (or a *-nvidia-open kernel package)."
            fi
        fi

        # Install NVIDIA drivers — CachyOS ships modules with its kernel packages
        if is_cachyos; then
            if pacman -Qq 2>/dev/null | grep -q 'nvidia-open'; then
                print_info "CachyOS kernel already provides the open NVIDIA modules"
            elif nvidia_requires_open_modules; then
                print_info "Installing open NVIDIA modules for CachyOS"
                sudo pacman -S --needed --noconfirm nvidia-open-dkms 2>/dev/null || \
                    print_warning "Install a linux-cachyos-*-nvidia-open kernel instead"
            fi
            sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils nvidia-settings 2>/dev/null || true
        elif nvidia_requires_open_modules; then
            aur_install nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings || true
        elif command_exists nvidia-inst; then
            # EndeavourOS nvidia installer
            sudo nvidia-inst --32 -f || true
        else
            aur_install nvidia nvidia-utils lib32-nvidia-utils nvidia-settings || true
        fi

        # Extra packages for Wayland/gaming
        aur_install \
            libva-nvidia-driver \
            egl-wayland \
            || true

        # NVIDIA gaming environment variables (safe, user-level only)
        # Ref: https://wiki.archlinux.org/title/Hardware_raytracing
        # Ref: https://github.com/jp7677/dxvk-nvapi
        ensure_directory "$HOME/.config/environment.d"
        cat > "$HOME/.config/environment.d/nvidia-gaming.conf" << 'EOF'
# NVIDIA Gaming optimizations (user-level, safe)
# Updated for RTX 50 series / open drivers (2025)

# Shader cache - prevent cleanup for large games
# (cache is enabled by default, this just prevents pruning)
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# DLSS support in Proton (required for DLSS to work)
PROTON_ENABLE_NVAPI=1

# Note: VKD3D_CONFIG=dxr is no longer needed (DXR enabled by default)
# Note: __GL_THREADED_OPTIMIZATIONS can hurt some apps, use per-game if needed
EOF

        print_success "NVIDIA gaming env vars configured"
    fi

    if has_amd_gpu; then
        print_info "AMD GPU detected (discrete or integrated)"
        aur_install mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon || true
    fi

    if has_intel_gpu; then
        print_info "Intel GPU detected"
        aur_install mesa vulkan-intel lib32-mesa lib32-vulkan-intel || true
    fi

    # KDE Plasma optimizations
    if is_kde_plasma; then
        setup_kde_plasma_optimizations
    fi

    # Backup pacman.conf before modifications
    if [[ ! -f /etc/pacman.conf.bak ]]; then
        sudo cp /etc/pacman.conf /etc/pacman.conf.bak
        print_info "Created backup: /etc/pacman.conf.bak"
    fi

    # EndeavourOS optimizations
    if is_endeavouros; then
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf || true
        sudo pacman -Sy || true
        aur_install welcome eos-update-notifier eos-update-notifier-plasma || true
    fi

    # Optimize pacman — CachyOS already has these enabled
    if ! is_cachyos; then
        sudo sed -i 's/#Color/Color/' /etc/pacman.conf
        sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
        sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
    else
        print_info "CachyOS detected — skipping pacman.conf modifications (already optimized)"
    fi

    print_success "Arch Linux optimizations applied"
}

setup_kde_plasma_optimizations() {
    print_info "Applying KDE Plasma 6 optimizations..."

    # Configure environment for Wayland
    ensure_directory "$HOME/.config/environment.d"

    # Base Wayland environment (safe for all GPUs)
    cat > "$HOME/.config/environment.d/wayland.conf" << 'EOF'
# Wayland environment variables for KDE Plasma 6
QT_QPA_PLATFORM=wayland;xcb
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
MOZ_ENABLE_WAYLAND=1
SDL_VIDEODRIVER=wayland,x11
_JAVA_AWT_WM_NONREPARENTING=1
CLUTTER_BACKEND=wayland
GDK_BACKEND=wayland,x11
EOF

    # NOTE: NVIDIA Wayland env vars (GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME, LIBVA_DRIVER_NAME)
    # are NO LONGER NEEDED with nvidia-utils 555+ (they're auto-detected).
    # Setting them manually can cause black screen issues on KDE Plasma 6.
    # See: https://wiki.archlinux.org/title/NVIDIA

    # Electron apps Wayland support
    cat > "$HOME/.config/electron-flags.conf" << 'EOF'
--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-features=WaylandWindowDecorations
EOF

    # Chrome/Chromium Wayland flags (both files for compatibility)
    local chrome_flags='--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-features=WaylandWindowDecorations'

    echo "$chrome_flags" > "$HOME/.config/chromium-flags.conf"
    echo "$chrome_flags" > "$HOME/.config/chrome-flags.conf"
    echo "$chrome_flags" > "$HOME/.config/google-chrome-flags.conf"

    # Configure KDE settings via kwriteconfig5/kwriteconfig6
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    if command_exists "$kwrite_cmd"; then
        print_info "Configuring KDE settings..."

        # NOTE: Do NOT set Compositing Backend - KDE Plasma 6 auto-detects the correct
        # backend for Wayland. Forcing OpenGL can cause black screen issues with NVIDIA.
        # See: https://discuss.kde.org/t/if-anybody-want-to-try-to-hunt-down-the-wayland-black-screen-in-plasma-6-with-nvidia-look-here/11607

        # Animation speed (0.5 = faster, 1.0 = normal, 0 = instant) - safe to set
        "$kwrite_cmd" --file kdeglobals --group KDE --key AnimationDurationFactor 0.5 2>/dev/null || true

        # Desktop effects - only disable problematic ones, don't force enable
        "$kwrite_cmd" --file kwinrc --group Plugins --key wobblywindowsEnabled false 2>/dev/null || true

        print_success "KDE settings applied"
    fi

    # Install essential KDE tools only (minimal set)
    print_info "Installing KDE utilities..."
    aur_install \
        plasma-systemmonitor \
        kdeconnect \
        kinfocenter \
        kde-gtk-config \
        breeze-gtk \
        kvantum \
        2>/dev/null || true

    # Copy Plasma layout if available
    if [[ -f "$CONFIGS_DIR/plasma-layout.js" ]]; then
        local plasma_dir="$HOME/.local/share/plasma/layout-templates/dev-setup"
        ensure_directory "$plasma_dir/contents"
        cp -f "$CONFIGS_DIR/plasma-layout.js" "$plasma_dir/contents/layout.js"
        print_info "Plasma layout template installed. Apply via: Right-click desktop → Enter Edit Mode → Add Panel → Templates"
    fi

    # Enable PipeWire services (important for Plasma 6 audio)
    print_info "Enabling PipeWire audio services..."
    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

    print_success "KDE Plasma 6 optimizations applied"
}

# ==========================================
# Nerd Fonts Installation
# ==========================================

install_nerd_fonts() {
    print_info "Installing Nerd Fonts..."

    # Required fonts used by configs:
    # - CaskaydiaCove Nerd Font (primary - terminal, editors, rofi)
    # - JetBrainsMono Nerd Font (fallback)
    # - Symbols Nerd Font (icon fallback)

    if is_macos; then
        # macOS - use Homebrew casks
        print_info "Installing fonts via Homebrew..."
        brew install --cask \
            font-caskaydia-cove-nerd-font \
            font-jetbrains-mono-nerd-font \
            font-symbols-only-nerd-font \
            font-fira-code-nerd-font \
            2>/dev/null || true
    else
        # Linux (Arch) - use pacman/yay
        if command_exists paru || command_exists yay; then
            print_info "Installing fonts via AUR helper..."
            aur_install \
                ttf-cascadia-code-nerd \
                ttf-jetbrains-mono-nerd \
                ttf-nerd-fonts-symbols \
                ttf-firacode-nerd \
                2>/dev/null || true
        elif command_exists pacman; then
            print_info "Installing fonts via pacman..."
            sudo pacman -S --needed --noconfirm \
                ttf-cascadia-code-nerd \
                ttf-jetbrains-mono-nerd \
                ttf-nerd-fonts-symbols \
                ttf-firacode-nerd \
                2>/dev/null || true
        else
            # Fallback: manual installation from GitHub releases
            print_info "Installing fonts manually from GitHub..."
            install_nerd_fonts_manual
        fi
    fi

    # Refresh font cache on Linux
    if ! is_macos && command_exists fc-cache; then
        print_info "Refreshing font cache..."
        fc-cache -fv >/dev/null 2>&1 || true
    fi

    # Verify installation
    verify_nerd_fonts
}

install_nerd_fonts_manual() {
    # Manual installation for systems without package managers
    local font_dir
    local nerd_fonts_version="v3.3.0"
    local base_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_fonts_version}"

    if is_macos; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi

    ensure_directory "$font_dir"
    local temp_dir=$(mktemp -d)

    print_info "Downloading Nerd Fonts to $temp_dir..."

    # Download and extract fonts
    for font in "CascadiaCode" "JetBrainsMono" "NerdFontsSymbolsOnly"; do
        local zip_file="$temp_dir/${font}.zip"
        print_info "Downloading ${font}..."
        if curl -fsSL "${base_url}/${font}.zip" -o "$zip_file"; then
            unzip -o -q "$zip_file" -d "$font_dir" 2>/dev/null || true
            rm -f "$zip_file"
        else
            print_warning "Failed to download ${font}"
        fi
    done

    rm -rf "$temp_dir"

    # Remove Windows-specific fonts
    find "$font_dir" -name "*Windows*" -delete 2>/dev/null || true
}

verify_nerd_fonts() {
    print_info "Verifying Nerd Font installation..."

    local missing_fonts=()
    local fonts_to_check=(
        "CaskaydiaCove Nerd Font"
        "JetBrainsMono Nerd Font"
    )

    if is_macos; then
        # macOS font verification
        for font in "${fonts_to_check[@]}"; do
            if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "${font%% *}"; then
                # Try alternative check
                if ! fc-list 2>/dev/null | grep -qi "${font%% *}"; then
                    missing_fonts+=("$font")
                fi
            fi
        done
    else
        # Linux font verification using fc-list
        if command_exists fc-list; then
            for font in "${fonts_to_check[@]}"; do
                if ! fc-list | grep -qi "${font%% *}"; then
                    missing_fonts+=("$font")
                fi
            done
        fi
    fi

    if [[ ${#missing_fonts[@]} -eq 0 ]]; then
        print_success "All required Nerd Fonts are installed"
    else
        print_warning "Some fonts may be missing: ${missing_fonts[*]}"
        print_info "You may need to restart your terminal or log out/in for fonts to appear"
    fi
}

# ==========================================
# Tokyo Night Theme Installation
# ==========================================

install_tokyo_night_themes() {
    local theme_base="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras"

    # Download themes for installed tools
    if command_exists kitty && [[ -d "$HOME/.config/kitty" ]]; then
        curl -fsSL "$theme_base/kitty/tokyonight_storm.conf" -o "$HOME/.config/kitty/tokyonight_storm.conf" 2>/dev/null || true
    fi

    if command_exists bat; then
        ensure_directory "$HOME/.config/bat/themes"
        curl -fsSL "$theme_base/sublime/tokyonight_storm.tmTheme" -o "$HOME/.config/bat/themes/tokyonight_storm.tmTheme" 2>/dev/null || true
        # Install bat config
        if [[ -f "$CONFIGS_DIR/bat/config" ]]; then
            cp -f "$CONFIGS_DIR/bat/config" "$HOME/.config/bat/config"
        fi
        bat cache --build >/dev/null 2>&1 || true
    fi

    if command_exists lazygit && [[ -d "$HOME/.config/lazygit" ]]; then
        # The theme is already integrated in our lazygit.yml config
        :
    fi

    if command_exists delta; then
        ensure_directory "$HOME/.config/git"
        curl -fsSL "$theme_base/delta/tokyonight_storm.gitconfig" -o "$HOME/.config/git/delta-tokyonight.gitconfig" 2>/dev/null || true
    fi

    if command_exists yazi && [[ -d "$HOME/.config/yazi" ]]; then
        # Do NOT overwrite theme.toml here -- this repo ships its own fixed
        # configs/yazi/theme.toml (current [mgr]/[icon] schema). Only fetch the
        # syntect highlighting theme it references via syntect_theme.
        curl -fsSL "$theme_base/sublime/tokyonight_storm.tmTheme" -o "$HOME/.config/yazi/tokyonight_storm.tmTheme" 2>/dev/null || true
    fi


    if command_exists zellij && [[ -d "$HOME/.config/zellij" ]]; then
        ensure_directory "$HOME/.config/zellij/themes"
        curl -fsSL "$theme_base/zellij/tokyonight_storm.kdl" -o "$HOME/.config/zellij/themes/tokyonight_storm.kdl" 2>/dev/null || true
    fi

    if command_exists gitui && [[ -d "$HOME/.config/gitui" ]]; then
        curl -fsSL "$theme_base/gitui/tokyonight_storm.ron" -o "$HOME/.config/gitui/theme.ron" 2>/dev/null || true
    fi
}

# ==========================================
# Mise Setup (Version Manager)
# ==========================================

setup_mise() {
    print_header "Setting up Mise (Universal Version Manager)"

    # Install mise
    if ! command_exists mise && [[ ! -f "$HOME/.local/bin/mise" ]]; then
        print_info "Installing mise..."
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        print_success "Mise already installed"
    fi
    
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

    # Install global tools with mise
    print_info "Installing development tools with mise..."

    # Install Node.js LTS
    "$mise_cmd" use --global node@lts || true

    # REMOVED: Python setup
    # "$mise_cmd" use --global python@3.12 || true

    # Install Bun
    "$mise_cmd" use --global bun@latest || true

    # REMOVED: Go setup
    # "$mise_cmd" use --global go@latest || true

    # Install Rust
    "$mise_cmd" use --global rust@latest || true

    # REMOVED: Other languages not needed for web/Rust dev
    # "$mise_cmd" use --global java@21 || true
    # "$mise_cmd" use --global ruby@latest || true

    print_success "Mise setup complete with global tools installed"
}

# ==========================================
# Terminal and Shell Setup
# ==========================================

setup_terminal_and_shell() {
    print_header "Terminal & Shell Setup"

    # Install terminal emulators (Ghostty is primary)
    if is_macos; then
        brew install --cask ghostty || true
        brew install --cask kitty || true  # Fallback
    else
        # Ghostty installation on Arch
        local aur_cmd=""; command_exists paru && aur_cmd="paru" || aur_cmd="yay"
        if $aur_cmd -Ss ghostty &>/dev/null; then
            aur_install ghostty || true
        else
            print_info "Ghostty not available in AUR, installing from official source..."
            # Install dependencies and build from source if needed
            aur_install gtk4 libadwaita || true
        fi
        aur_install kitty || true  # Fallback
    fi

    # Configure Ghostty (primary terminal)
    if [[ -f "$CONFIGS_DIR/ghostty.conf" ]]; then
        ensure_directory "$HOME/.config/ghostty"
        cp -f "$CONFIGS_DIR/ghostty.conf" "$HOME/.config/ghostty/config"
        print_success "Ghostty configured as default terminal"

        # Setup Ghostty drop-down terminal script on Linux
        if is_linux && [[ -f "$CONFIGS_DIR/scripts/ghostty-dropdown.sh" ]]; then
            ensure_directory "$HOME/.local/bin"
            cp -f "$CONFIGS_DIR/scripts/ghostty-dropdown.sh" "$HOME/.local/bin/ghostty-dropdown"
            chmod +x "$HOME/.local/bin/ghostty-dropdown"
            print_success "Ghostty drop-down script installed"

            # Create desktop file for KDE shortcut
            if is_kde_plasma; then
                ensure_directory "$HOME/.local/share/applications"
                cat > "$HOME/.local/share/applications/ghostty-dropdown.desktop" << 'EOF'
[Desktop Entry]
Name=Ghostty Dropdown Terminal
Comment=Toggle drop-down terminal (Quake-style)
Exec=$HOME/.local/bin/ghostty-dropdown
Icon=utilities-terminal
Type=Application
Categories=Utility;TerminalEmulator;
NoDisplay=true
EOF
                # Fix the $HOME in Exec path
                sed -i "s|\$HOME|$HOME|g" "$HOME/.local/share/applications/ghostty-dropdown.desktop"
                update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

                # Configure F12 shortcut
                local kwrite_cmd="kwriteconfig5"
                command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"
                "$kwrite_cmd" --file kglobalshortcutsrc --group ghostty-dropdown.desktop --key _launch "F12,F12,Ghostty Dropdown Terminal"

                print_success "Ghostty dropdown shortcut configured (F12)"
            fi
        fi
    fi

    # Configure Kitty (fallback)
    if command_exists kitty && [[ -f "$CONFIGS_DIR/kitty.conf" ]]; then
        ensure_directory "$HOME/.config/kitty"
        cp -f "$CONFIGS_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        [[ -f "$CONFIGS_DIR/kitty-session.conf" ]] && cp -f "$CONFIGS_DIR/kitty-session.conf" "$HOME/.config/kitty/kitty-session.conf"
    fi

    # Install Nerd Fonts
    install_nerd_fonts

    # Install CLI tools
    if is_macos; then
        brew install eza bat ripgrep ast-grep fd fzf zoxide direnv btop dust duf gping procs neofetch topgrade jq yq xsv xh mtr nmap bandwhich doggo miniserve cloudflared tldr hyperfine tokei gh tree watch yazi asciinema noti vivid zellij zsh starship || true
    else
        # Split into groups so one failure doesn't block the rest
        aur_install eza bat ripgrep fd fzf zoxide direnv btop zsh starship zellij || true
        aur_install dust duf gping procs topgrade jq yq tree procps-ng yazi vivid || true
        aur_install xh mtr nmap tldr hyperfine tokei github-cli asciinema || true
        aur_install ast-grep xsv bandwhich doggo miniserve cloudflared-bin noti wmctrl xdotool || true
    fi

    # Configure Yazi
    if command_exists yazi && [[ -d "$CONFIGS_DIR/yazi" ]]; then
        ensure_directory "$HOME/.config/yazi"
        [[ -f "$CONFIGS_DIR/yazi/yazi.toml" ]] && cp -f "$CONFIGS_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
        [[ -f "$CONFIGS_DIR/yazi/keymap.toml" ]] && cp -f "$CONFIGS_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
        [[ -f "$CONFIGS_DIR/yazi/theme.toml" ]] && cp -f "$CONFIGS_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    fi

    # Set Zsh as default shell
    if command_exists zsh && [[ "$SHELL" != *"zsh"* ]]; then
        print_info "Setting Zsh as default shell"
        if is_macos; then
            chsh -s /bin/zsh || true
        else
            local zsh_path
            zsh_path=$(command -v zsh)
            # chsh refuses shells absent from /etc/shells; register first.
            if [[ -n "$zsh_path" ]] && ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
            fi
            chsh -s "$zsh_path" || true
        fi
    fi

    # Install zinit
    local ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if ! [[ -d "$ZINIT_HOME" ]]; then
        ensure_directory "$(dirname "$ZINIT_HOME")"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || true
    fi

    # Install shell configurations
    print_info "Installing shell configurations..."

    # Install zshrc (already contains mise activation)
    if [[ -f "$CONFIGS_DIR/zshrc" ]]; then
        cp -f "$CONFIGS_DIR/zshrc" "$HOME/.zshrc"
        print_success "Installed .zshrc"
    fi

    # Install aliases
    if [[ -f "$CONFIGS_DIR/aliases.sh" ]]; then
        ensure_directory "$HOME/.config/shell"
        cp -f "$CONFIGS_DIR/aliases.sh" "$HOME/.config/shell/aliases.sh"
        print_success "Installed aliases.sh"
    fi

    # Install project templates
    if [[ -f "$CONFIGS_DIR/project-templates.sh" ]]; then
        cp -f "$CONFIGS_DIR/project-templates.sh" "$HOME/.config/shell/project-templates.sh"
        chmod +x "$HOME/.config/shell/project-templates.sh"
        print_success "Installed project-templates.sh"
    fi

    # Install Starship prompt config
    if [[ -f "$CONFIGS_DIR/starship.toml" ]]; then
        ensure_directory "$HOME/.config"
        cp -f "$CONFIGS_DIR/starship.toml" "$HOME/.config/starship.toml"
        print_success "Installed starship.toml"
    fi

    # Install project template directory if exists
    if [[ -d "$CONFIGS_DIR/project-templates" ]]; then
        ensure_directory "$HOME/.config"
        cp -rf "$CONFIGS_DIR/project-templates" "$HOME/.config/project-templates"
        print_info "Project templates installed to ~/.config/project-templates"
    fi

    # Install tool configurations
    for tool in btop lazygit topgrade ripgrep; do
        if command_exists "$tool"; then
            case "$tool" in
                btop)
                    [[ -f "$CONFIGS_DIR/btop.conf" ]] && ensure_directory "$HOME/.config/btop" && cp -f "$CONFIGS_DIR/btop.conf" "$HOME/.config/btop/btop.conf"
                    ;;
                lazygit)
                    [[ -f "$CONFIGS_DIR/lazygit.yml" ]] && ensure_directory "$HOME/.config/lazygit" && cp -f "$CONFIGS_DIR/lazygit.yml" "$HOME/.config/lazygit/config.yml"
                    ;;
                topgrade)
                    [[ -f "$CONFIGS_DIR/topgrade.toml" ]] && ensure_directory "$HOME/.config/topgrade" && cp -f "$CONFIGS_DIR/topgrade.toml" "$HOME/.config/topgrade/topgrade.toml"
                    ;;
                ripgrep)
                    [[ -f "$CONFIGS_DIR/ripgreprc" ]] && cp -f "$CONFIGS_DIR/ripgreprc" "$HOME/.ripgreprc"
                    ;;
            esac
        fi
    done

    # Install vivid theme
    if command_exists vivid && [[ -f "$CONFIGS_DIR/tokyonight-storm.yml" ]]; then
        ensure_directory "$HOME/.config/vivid/themes"
        cp -f "$CONFIGS_DIR/tokyonight-storm.yml" "$HOME/.config/vivid/themes/tokyonight-storm.yml"
    fi

    # Configure Zellij
    if command_exists zellij && [[ -f "$CONFIGS_DIR/zellij.kdl" ]]; then
        ensure_directory "$HOME/.config/zellij"
        cp -f "$CONFIGS_DIR/zellij.kdl" "$HOME/.config/zellij/config.kdl"
        # Install layouts
        if [[ -d "$CONFIGS_DIR/zellij-layouts" ]]; then
            ensure_directory "$HOME/.config/zellij/layouts"
            cp -f "$CONFIGS_DIR/zellij-layouts/"*.kdl "$HOME/.config/zellij/layouts/" 2>/dev/null || true
        fi
    fi

    # Install Tokyo Night themes for installed tools
    install_tokyo_night_themes

    # Set Ghostty as default terminal
    set_default_terminal

    # Set Chrome as default browser
    set_default_browser "chrome"

    # Setup Rofi launcher (Linux only)
    setup_rofi

    print_success "Terminal and shell setup complete"
}

# ==========================================
# Rofi Launcher Setup (Wayland/KDE Plasma)
# ==========================================

setup_kde_rofi_shortcuts() {
    # Setup KDE Plasma custom shortcuts for Rofi
    # KDE Plasma 6 uses kglobalshortcutsrc with custom service files

    if ! is_kde_plasma; then
        return 0
    fi

    print_info "Configuring Rofi shortcuts for KDE Plasma..."

    # Create desktop files for rofi commands
    ensure_directory "$HOME/.local/share/applications"

    # Rofi App Launcher
    cat > "$HOME/.local/share/applications/rofi-launcher.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Launcher
Comment=Application launcher
Exec=rofi -show drun
Icon=rofi
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Window Switcher
    cat > "$HOME/.local/share/applications/rofi-window.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Window Switcher
Comment=Switch between windows
Exec=rofi -show window
Icon=rofi
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Clipboard
    cat > "$HOME/.local/share/applications/rofi-clipboard.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Clipboard
Comment=Clipboard history
Exec=~/.config/rofi/scripts/clipboard.sh
Icon=edit-paste
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Power Menu
    cat > "$HOME/.local/share/applications/rofi-powermenu.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Power Menu
Comment=Power options
Exec=~/.config/rofi/scripts/powermenu.sh
Icon=system-shutdown
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Rofi Screenshot
    cat > "$HOME/.local/share/applications/rofi-screenshot.desktop" << 'EOF'
[Desktop Entry]
Name=Rofi Screenshot
Comment=Screenshot tool
Exec=~/.config/rofi/scripts/screenshot.sh
Icon=camera-photo
Type=Application
Categories=Utility;
NoDisplay=true
EOF

    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

    # Configure shortcuts via kglobalshortcutsrc
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    # Alt+Space for Rofi launcher (main)
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-launcher.desktop --key _launch "Alt+Space,Alt+Space,Rofi Launcher"

    # Alt+Tab alternative with Rofi window switcher
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-window.desktop --key _launch "Alt+Shift+Tab,Alt+Shift+Tab,Rofi Window Switcher"

    # Alt+V for clipboard history
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-clipboard.desktop --key _launch "Alt+V,Alt+V,Rofi Clipboard"

    # Alt+Shift+P for power menu
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-powermenu.desktop --key _launch "Alt+Shift+P,Alt+Shift+P,Rofi Power Menu"

    # Print Screen for screenshot
    "$kwrite_cmd" --file kglobalshortcutsrc --group rofi-screenshot.desktop --key _launch "Print,Print,Rofi Screenshot"

    # Reload KDE shortcuts daemon to apply changes
    if command_exists kquitapp6; then
        kquitapp6 kglobalaccel 2>/dev/null && sleep 1 && kglobalaccel6 &>/dev/null &
    fi

    print_success "Rofi shortcuts configured"
    print_info "  Alt+Space     → App Launcher"
    print_info "  Alt+V         → Clipboard History"
    print_info "  Alt+Shift+P   → Power Menu"
    print_info "  Print         → Screenshot"
}

setup_rofi() {
    # Rofi is Linux-only
    if is_macos; then
        return 0
    fi

    print_info "Setting up Rofi launcher..."

    # Install rofi and dependencies (rofi now has native Wayland support)
    aur_install rofi-wayland papirus-icon-theme || \
    aur_install rofi papirus-icon-theme || true

    # Install Wayland screenshot/clipboard tools
    aur_install grim slurp wl-clipboard cliphist || true

    # Copy rofi configuration
    if [[ -d "$CONFIGS_DIR/rofi" ]]; then
        ensure_directory "$HOME/.config/rofi"
        ensure_directory "$HOME/.config/rofi/scripts"

        cp -f "$CONFIGS_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

        # Copy and make scripts executable
        if [[ -d "$CONFIGS_DIR/rofi/scripts" ]]; then
            cp -f "$CONFIGS_DIR/rofi/scripts/"*.sh "$HOME/.config/rofi/scripts/" 2>/dev/null || true
            chmod +x "$HOME/.config/rofi/scripts/"*.sh 2>/dev/null || true
        fi

        print_success "Rofi configuration installed"
    fi

    # Setup cliphist to run with Wayland session
    if command_exists cliphist; then
        ensure_directory "$HOME/.config/systemd/user"

        # Create cliphist service for clipboard history
        cat > "$HOME/.config/systemd/user/cliphist.service" << 'EOF'
[Unit]
Description=Clipboard history service
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/wl-paste --watch cliphist store
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

        # Enable cliphist service
        systemctl --user daemon-reload
        systemctl --user enable --now cliphist.service 2>/dev/null || true
        print_success "Clipboard history service enabled"
    fi
}

# ==========================================
# Set Default Terminal and Browser
# ==========================================

set_default_terminal() {
    print_info "Setting Ghostty as default terminal..."

    if is_macos; then
        # macOS: Set default terminal via Launch Services
        # Ghostty registers itself, but we can set it as default handler
        if [[ -d "/Applications/Ghostty.app" ]]; then
            # Set Ghostty as default terminal emulator
            defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                '{LSHandlerContentType = "public.unix-executable"; LSHandlerRoleAll = "com.mitchellh.ghostty";}' 2>/dev/null || true
            print_success "Ghostty set as default terminal on macOS"
        fi
    elif is_kde_plasma; then
        # KDE Plasma: Set default terminal via kwriteconfig
        local kwrite_cmd="kwriteconfig5"
        command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

        if command_exists "$kwrite_cmd"; then
            "$kwrite_cmd" --file kdeglobals --group General --key TerminalApplication ghostty
            "$kwrite_cmd" --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
            print_success "Ghostty set as default terminal on KDE Plasma"
        fi

        # Also set via xdg-mime for other apps
        if command_exists xdg-mime; then
            xdg-mime default com.mitchellh.ghostty.desktop x-scheme-handler/terminal 2>/dev/null || true
        fi

        # update-alternatives is Debian-only, skip on Arch
    fi
}

set_default_browser() {
    local browser="$1"
    print_info "Setting $browser as default browser..."

    if is_macos; then
        # macOS: Use defaultbrowser tool or open command
        case "$browser" in
            firefox)
                open -a "Firefox" --args --make-default-browser 2>/dev/null || true
                ;;
            chrome|google-chrome)
                open -a "Google Chrome" --args --make-default-browser 2>/dev/null || true
                ;;
            zen)
                # Zen browser - set via Launch Services
                defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                    '{LSHandlerURLScheme = http; LSHandlerRoleAll = "zen.browser";}' 2>/dev/null || true
                defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                    '{LSHandlerURLScheme = https; LSHandlerRoleAll = "zen.browser";}' 2>/dev/null || true
                ;;
        esac
        print_success "$browser set as default browser on macOS"
    elif is_linux; then
        # Linux: Use xdg-settings
        if command_exists xdg-settings; then
            case "$browser" in
                firefox)
                    xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
                    ;;
                chrome|google-chrome)
                    xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null || true
                    ;;
                zen)
                    xdg-settings set default-web-browser zen.desktop 2>/dev/null || \
                    xdg-settings set default-web-browser zen-browser.desktop 2>/dev/null || true
                    ;;
            esac
            print_success "$browser set as default browser on Linux"
        fi
    fi
}

# ==========================================
# Git Configuration
# ==========================================

setup_git() {
    print_header "Git Configuration"

    # Install git tools
    if is_macos; then
        brew install git git-delta lazygit gitui || true
    else
        aur_install git git-delta lazygit gitui || true
    fi

    # Configure Git
    if command_exists git; then
        # Get user info
        local current_name=$(git config --global user.name 2>/dev/null || echo "")
        local current_email=$(git config --global user.email 2>/dev/null || echo "")
        local git_name="$current_name"
        local git_email="$current_email"
        
        # Prompt for name if not set
        if [[ -z "$git_name" ]]; then
            print_info "Git user name not configured"
            read -p "Enter your name for Git commits: " git_name
            if [[ -z "$git_name" ]]; then
                git_name="Developer"
                print_warning "Using default name: Developer"
            fi
        fi
        
        # Prompt for email if not set
        if [[ -z "$git_email" ]]; then
            print_info "Git user email not configured"
            read -p "Enter your email for Git commits: " git_email
            if [[ -z "$git_email" ]]; then
                git_email="developer@example.com"
                print_warning "Using default email: developer@example.com"
            fi
        fi

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

        # Generate SSH key if needed
        local ssh_key="$HOME/.ssh/id_ed25519"
        if [[ ! -f "$ssh_key" ]]; then
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"
            print_info "You can set a passphrase for extra security (press Enter for none)"
            ssh-keygen -t ed25519 -C "$git_email" -f "$ssh_key"
            chmod 600 "$ssh_key"
            chmod 644 "${ssh_key}.pub"
            print_info "SSH key generated. Public key:"
            cat "${ssh_key}.pub"
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

# ==========================================
# Development Tools
# ==========================================

# ==========================================
# Docker Setup (Linux)
# ==========================================

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

# ==========================================
# Development Tools Setup
# ==========================================

# cargo-binstall pulls prebuilt binaries instead of compiling each tool from source
setup_rust_tooling() {
    command_exists cargo || { print_warning "cargo not found — skipping Rust tooling"; return 0; }

    local tools=(
        cargo-watch cargo-edit cargo-outdated cargo-audit cargo-expand
        cargo-nextest bacon
    )

    if command_exists cargo-binstall; then
        print_step "Installing Rust tools via cargo-binstall..."
        cargo binstall --no-confirm --disable-telemetry "${tools[@]}" 2>/dev/null || \
            cargo install "${tools[@]}" || true
    else
        cargo install "${tools[@]}" || true
    fi

    # wasm32 target for web/WASM work (Leptos, Yew, wasm-pack, Bevy web builds)
    if command_exists rustup; then
        rustup target add wasm32-unknown-unknown 2>/dev/null || true
        rustup component add rust-analyzer clippy rustfmt 2>/dev/null || true
    fi

    print_success "Rust tooling installed"
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

    # Build tools for Rust/Web/C++ development
    if is_macos; then
        brew install cmake ninja just || true
    else
        aur_install base-devel cmake ninja gcc clang just || true
    fi

    # Ensure mise-managed tools are available
    export PATH="$HOME/.local/share/mise/shims:$PATH"

    # REMOVED: Python tools
    # Node/JS tools only
    if is_macos; then
        brew install pnpm yarn || true
    else
        aur_install pnpm yarn || true
    fi

    # Rust toolchain support tools
    if is_macos; then
        brew install cargo-binstall sccache wasm-pack || true
    else
        # mold: dramatically faster linking, which dominates Rust rebuild time
        aur_install cargo-binstall sccache wasm-pack mold lld || true
    fi

    # Bun is already installed via mise

    setup_rust_tooling
    setup_rust_cargo_config

    # Code Editors
    if is_macos; then
        brew install neovim || true
        brew install --cask visual-studio-code zed || true
    else
        aur_install neovim visual-studio-code-bin zed || true
    fi

    # Configure Neovim (LazyVim)
    if command_exists nvim; then
        [[ -d "$HOME/.config/nvim" ]] && backup_file "$HOME/.config/nvim" && rm -rf "$HOME/.config/nvim"
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" || true
        # Install LazyVim config
        [[ -f "$CONFIGS_DIR/lazyvim.json" ]] && cp -f "$CONFIGS_DIR/lazyvim.json" "$HOME/.config/nvim/lazyvim.json"
    fi

    # DISABLED: VS Code configuration
    # # Configure VS Code
    # if command_exists code && [[ -d "$CONFIGS_DIR/vscode" ]]; then
    #     local vscode_dir=""
    #     if is_macos; then
    #         vscode_dir="$HOME/Library/Application Support/Code/User"
    #     else
    #         vscode_dir="$HOME/.config/Code/User"
    #     fi
    #     ensure_directory "$vscode_dir"
    #     [[ -f "$CONFIGS_DIR/vscode/settings.json" ]] && cp -f "$CONFIGS_DIR/vscode/settings.json" "$vscode_dir/settings.json"
    #     [[ -f "$CONFIGS_DIR/vscode/keybindings.json" ]] && cp -f "$CONFIGS_DIR/vscode/keybindings.json" "$vscode_dir/keybindings.json"
    #     [[ -d "$CONFIGS_DIR/vscode/snippets" ]] && cp -rf "$CONFIGS_DIR/vscode/snippets" "$vscode_dir/snippets"

    #     # Install extensions
    #     if [[ -f "$CONFIGS_DIR/vscode/extensions.txt" ]]; then
    #         print_info "Installing VS Code extensions..."
    #         # Get list of installed extensions
    #         local installed_extensions=$(code --list-extensions 2>/dev/null || echo "")

    #         while IFS= read -r ext; do
    #             [[ -z "$ext" || "$ext" =~ ^# ]] && continue
    #             # Check if extension is already installed
    #             if ! echo "$installed_extensions" | grep -qi "^${ext}$"; then
    #                 code --install-extension "$ext" --force 2>/dev/null || true
    #             fi
    #         done < "$CONFIGS_DIR/vscode/extensions.txt"
    #     fi
    # fi


    # Configure Zed
    if command_exists zed && [[ -d "$CONFIGS_DIR/zed" ]]; then
        local zed_dir="$HOME/.config/zed"
        ensure_directory "$zed_dir"
        [[ -f "$CONFIGS_DIR/zed/settings.json" ]] && cp -f "$CONFIGS_DIR/zed/settings.json" "$zed_dir/settings.json"
        [[ -f "$CONFIGS_DIR/zed/keymap.json" ]] && cp -f "$CONFIGS_DIR/zed/keymap.json" "$zed_dir/keymap.json"
    fi


    # Container Tools
    if is_macos; then
        brew install docker docker-buildx docker-compose colima lazydocker || true

        # Configure Colima
        if command_exists colima && [[ -f "$CONFIGS_DIR/colima/colima.yaml" ]]; then
            # Check if Colima is already running
            if colima status &>/dev/null; then
                echo "Colima is already running. Stopping to apply new configuration..."
                colima stop || true
            fi

            # Ensure config directory exists
            ensure_directory "$HOME/.colima/default"

            # Copy optimized configuration
            cp -f "$CONFIGS_DIR/colima/colima.yaml" "$HOME/.colima/default/colima.yaml"
            echo "Applied optimized Colima configuration"

            # Start Colima with the configuration file
            # The configuration file already contains all optimal settings
            echo "Starting Colima with optimized settings..."
            colima start || true

            # Verify Colima is using VirtioFS
            if colima status 2>/dev/null | grep -q "mountType: virtiofs"; then
                echo "✓ Colima is using VirtioFS for optimal performance"
            fi
        fi
    else
        # Install Docker and tools
        aur_install docker docker-buildx docker-compose lazydocker || true

        # Setup Docker permissions and group
        setup_docker_linux
    fi

    # REMOVED: Database GUI tools - use web-based tools instead

    # API Tools for web development
    if is_macos; then
        brew install httpie || true
        brew install --cask insomnia || true
    else
        aur_install httpie insomnia-bin || true
    fi

    # Essential container tools only
    if is_macos; then
        brew install mkcert || true
    else
        aur_install mkcert || true
    fi

    # Mise handles most version management now
    # Only keeping specialized toolchains

    # REMOVED: Haskell toolchain not needed for web/Rust dev

    # Claude Code CLI (native installer)
    print_info "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash -s -- --force || true

    # GitHub CLI Copilot extension
    if command_exists gh; then
        print_info "Installing GitHub CLI Copilot extension..."
        gh extension install github/gh-copilot 2>/dev/null || gh extension upgrade gh-copilot 2>/dev/null || true
    fi

    print_success "Development tools setup complete"
}

# ==========================================
# Productivity Apps
# ==========================================

setup_productivity_apps() {
    print_header "Gaming & Productivity Applications"

    # Window Management (useful for gaming too)
    if is_macos; then
        brew install --cask rectangle stats || true
    fi

    # System Monitoring (for gaming performance)
    if is_macos; then
        # Already installed with terminal tools
        :
    elif is_kde_plasma; then
        aur_install plasma-systemmonitor || true
    fi

    # App Launchers
    if is_macos; then
        brew install --cask raycast || true
    elif is_kde_plasma; then
        # DISABLED: Rofi setup
        # aur_install rofi-wayland || true

        # # Configure Rofi
        # if command_exists rofi && [[ -d "$CONFIGS_DIR/rofi" ]]; then
        #     ensure_directory "$HOME/.config/rofi"
        #     [[ -f "$CONFIGS_DIR/rofi/config.rasi" ]] && cp -f "$CONFIGS_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
        #     [[ -f "$CONFIGS_DIR/rofi/config-improved.rasi" ]] && cp -f "$CONFIGS_DIR/rofi/config-improved.rasi" "$HOME/.config/rofi/config-improved.rasi"

        #     # Install rofi scripts
        #     if [[ -d "$CONFIGS_DIR/rofi/scripts" ]]; then
        #         ensure_directory "$HOME/.config/rofi/scripts"
        #         cp -f "$CONFIGS_DIR/rofi/scripts/"*.sh "$HOME/.config/rofi/scripts/"
        #         chmod +x "$HOME/.config/rofi/scripts/"*.sh

        #         # Install dependencies for rofi scripts
        #         aur_install rofi-calc rofimoji rofi-power-menu wl-clipboard slurp grim swappy tesseract tesseract-data-eng || true
        #     fi
        # fi
        :
    fi

    # Gaming platforms and tools
    if is_macos; then
        brew install --cask steam || true
    else
        # Steam and gaming essentials for Linux (optional — ~2GB+ download)
        read -p "Install gaming packages (Steam, Lutris, Wine, MangoHud)? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping gaming packages"
        else

        aur_install \
            steam \
            lutris \
            wine-staging \
            winetricks \
            gamemode lib32-gamemode \
            mangohud lib32-mangohud \
            gamescope \
            goverlay \
            protonup-qt \
            vulkan-tools \
            vkbasalt lib32-vkbasalt \
            || true

        # Only meaningful if the package actually landed — the group is created by it
        if getent group gamemode &>/dev/null; then
            sudo usermod -aG gamemode "$USER" || true
        else
            print_warning "gamemode group missing — package install likely failed"
        fi

        # GameMode config for performance
        ensure_directory "$HOME/.config/gamemode"
        cat > "$HOME/.config/gamemode.ini" << 'EOF'
[general]
renice=10
softrealtime=auto
reaper_freq=5
desiredgov=performance
igpu_desiredgov=performance
igpu_power_threshold=0.3

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high
nv_powermizer_mode=1
nv_core_clock_mhz_offset=0
nv_mem_clock_mhz_offset=0

[custom]
start=notify-send "GameMode" "Gaming optimizations enabled"
end=notify-send "GameMode" "Gaming optimizations disabled"
EOF

        # MangoHud config
        ensure_directory "$HOME/.config/MangoHud"
        cat > "$HOME/.config/MangoHud/MangoHud.conf" << 'EOF'
# MangoHud Configuration
legacy_layout=false
gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock
gpu_power
gpu_load_change
gpu_load_value=50,90
gpu_load_color=FFFFFF,FFAA7F,CC0000
cpu_stats
cpu_temp
cpu_power
cpu_mhz
cpu_load_change
core_load_change
cpu_load_value=50,90
cpu_load_color=FFFFFF,FFAA7F,CC0000
io_read
io_write
vram
ram
fps
fps_color_change
fps_value=30,60
fps_color=CC0000,FFAA7F,FFFFFF
frametime=0
frame_timing
histogram
engine_version
vulkan_driver
wine
position=top-left
round_corners=5
background_alpha=0.5
font_size=20
toggle_hud=Shift_R+F12
toggle_fps_limit=Shift_L+F1
EOF

        # Steam launch options helper
        print_info "Recommended Steam launch options:"
        print_info "  gamemoderun mangohud %command%"
        print_info "  PROTON_ENABLE_NVAPI=1 gamemoderun %command%  (for NVIDIA DLSS)"
        fi
    fi

    # Screen Recording (for gaming clips)
    if is_macos; then
        brew install --cask obs || true
    else
        aur_install obs-studio || true
    fi

    print_success "Productivity apps setup complete"
}

# ==========================================
# Game Development
# ==========================================

setup_game_development() {
    print_header "Game Development"

    read -p "Install game development tools (engines, Vulkan SDK, profilers)? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && { print_info "Skipping game development tools"; return 0; }

    if is_macos; then
        brew install --cask godot blender || true
        brew install molten-vk || true
        print_success "Game development tools installed"
        return 0
    fi

    # Engines and content tools
    aur_install godot blender || true

    # Vulkan: loader, headers, and the validation layers you actually debug against
    aur_install \
        vulkan-headers \
        vulkan-tools \
        vulkan-validation-layers lib32-vulkan-validation-layers \
        vulkan-icd-loader lib32-vulkan-icd-loader \
        spirv-tools \
        glslang \
        shaderc \
        || true

    # Graphics debugging and profiling
    aur_install renderdoc || true
    aur_install tracy || print_info "tracy unavailable — skip or build from source"

    # System libraries Rust engines (Bevy, macroquad, winit) link against on Linux
    aur_install \
        alsa-lib \
        libxkbcommon \
        libx11 libxi libxcursor libxrandr libxinerama \
        wayland wayland-protocols \
        systemd-libs \
        fontconfig \
        || true

    # Native debugging
    aur_install lldb gdb || true

    print_success "Game development tools installed"
    print_info "Vulkan validation: VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation <binary>"
    print_info "Verify the stack with: vulkaninfo --summary"
}

# ==========================================
# CachyOS / AMD Hardware Tuning
# ==========================================

setup_cachyos_tuning() {
    is_linux || return 0
    is_arch_linux || return 0

    print_header "Hardware Tuning"

    # ---- CPU frequency driver ----
    local drv epp
    drv=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo unknown)
    epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo n/a)
    print_info "CPU scaling driver: $drv (EPP: $epp)"
    if [[ "$drv" == "acpi-cpufreq" ]] && grep -qi 'amd' /proc/cpuinfo; then
        print_warning "amd_pstate is not active — add amd_pstate=active to the kernel cmdline for better scaling"
    fi

    # ---- Asymmetric X3D CCD switching ----
    if has_amd_x3d_switch; then
        print_step "Installing x3d-mode helper..."
        # Root-owned in /usr/local/bin: it writes to sysfs via sudo, so it must not
        # be user-writable.
        sudo install -o root -g root -m 755 \
            "$CONFIGS_DIR/scripts/x3d-mode.sh" /usr/local/bin/x3d-mode
        print_success "x3d-mode installed"
        print_info "Current mode: $(cat /sys/bus/platform/drivers/amd_x3d_vcache/*/amd_x3d_mode 2>/dev/null)"
        print_info "  x3d-mode cache      -> prefer V-Cache CCD (gaming)"
        print_info "  x3d-mode frequency  -> prefer high-clock CCD (compiling)"

        setup_x3d_gamemode_hook
    fi

    # ---- sched_ext ----
    if has_sched_ext; then
        print_info "sched_ext is available in this kernel"
        if command_exists scx_loader && systemctl list-unit-files scx_loader.service &>/dev/null; then
            if [[ $(systemctl is-enabled scx_loader.service 2>/dev/null) != enabled ]]; then
                echo
                read -p "Enable scx_loader (pluggable schedulers, e.g. scx_lavd for gaming)? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sudo systemctl enable --now scx_loader.service || print_warning "Could not enable scx_loader"
                    print_success "scx_loader enabled"
                fi
            else
                print_info "scx_loader already enabled"
            fi
            command_exists scx-manager && print_info "Pick a scheduler with: scx-manager (GUI)"
            print_info "Or try one directly: sudo scx_lavd   (latency-tuned, good for games)"
        fi
    fi

    print_success "Hardware tuning complete"
}

# Switch to the V-Cache CCD while a game runs, back to high-clock when it exits.
# Needs a NOPASSWD sudoers entry, so it is strictly opt-in.
setup_x3d_gamemode_hook() {
    local gm_ini="$HOME/.config/gamemode.ini"
    command_exists gamemoded || return 0
    [[ -f "$gm_ini" ]] || return 0
    grep -q 'x3d-mode' "$gm_ini" && { print_info "GameMode X3D hook already configured"; return 0; }

    echo
    print_warning "Optional: switch to the V-Cache CCD automatically while games run."
    print_warning "This requires a sudoers rule letting your user run exactly two commands"
    print_warning "without a password: '/usr/local/bin/x3d-mode cache' and '... frequency'."
    read -p "Configure this? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && { print_info "Skipped X3D GameMode hook"; return 0; }

    local sudoers=/etc/sudoers.d/10-x3d-mode
    sudo tee "$sudoers" > /dev/null << EOF
$USER ALL=(root) NOPASSWD: /usr/local/bin/x3d-mode cache, /usr/local/bin/x3d-mode frequency
EOF
    sudo chmod 0440 "$sudoers"

    if ! sudo visudo -c -f "$sudoers" &>/dev/null; then
        sudo rm -f "$sudoers"
        print_error "sudoers validation failed — rule removed, no changes made"
        return 1
    fi

    backup_file "$gm_ini"
    sed -i 's|^start=.*|&\nstart=/usr/local/bin/x3d-mode cache|; s|^end=.*|&\nend=/usr/local/bin/x3d-mode frequency|' "$gm_ini"
    print_success "GameMode will switch CCD preference automatically"
}

# ==========================================
# Gaming Network (host firewall + router UPnP)
# ==========================================

setup_gaming_network() {
    is_linux || return 0

    print_header "Gaming Network"

    # upnpc talks to the router's IGD; gamenet needs it to diagnose the router layer
    if ! command_exists upnpc; then
        print_step "Installing miniupnpc..."
        aur_install miniupnpc || print_warning "Could not install miniupnpc"
    fi

    ensure_directory "$HOME/.local/bin"
    for tool in game-firewall gamenet; do
        cp -f "$CONFIGS_DIR/scripts/${tool}.sh" "$HOME/.local/bin/$tool"
        chmod +x "$HOME/.local/bin/$tool"
    done
    print_success "Installed game-firewall and gamenet to ~/.local/bin"

    if ! command_exists ufw; then
        print_info "ufw not installed - nothing is blocking inbound game traffic"
    elif [[ $(systemctl is-active ufw 2>/dev/null) != active ]]; then
        print_info "ufw installed but inactive - run 'sudo game-firewall' if you enable it later"
    else
        print_warning "ufw is active and defaults to dropping inbound connections."
        print_info "This blocks hosted games AND the router's UPnP replies, so games cannot"
        print_info "forward their own ports either. Both fail silently."
        echo
        read -p "Open the firewall for multiplayer game hosting? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo "$HOME/.local/bin/game-firewall" || print_warning "game-firewall failed"
        else
            print_info "Skipped. Run 'sudo game-firewall' later."
        fi
    fi

    echo
    print_info "Router side: enable UPnP in your router admin UI, and give this machine"
    print_info "a static DHCP lease. Then verify the whole chain with:  gamenet check"

    print_success "Gaming network setup complete"
}

# ==========================================
# Advanced/Specialized Tools
# ==========================================

setup_advanced_tools() {
    print_header "Communication & Media Tools"

    # Performance Tools for development
    if is_macos; then
        brew install hyperfine tokei || true
    else
        aur_install hyperfine tokei || true
    fi

    # Media tools (useful for web dev and gaming)
    if is_macos; then
        brew install imagemagick ffmpeg || true
    else
        aur_install imagemagick ffmpeg || true
    fi

    # Browser (Chrome as default)
    if is_macos; then
        brew install --cask google-chrome || true
    else
        aur_install google-chrome || true
    fi

    # Communication Tools (Discord for gaming, Slack for work)
    if is_macos; then
        brew install --cask discord slack 1password || true
    else
        aur_install discord slack-desktop-wayland 1password || true
    fi

    print_success "Communication & media tools setup complete"
}

# ==========================================
# Keyboard Shortcuts Setup
# ==========================================

setup_keyboard_shortcuts() {
    print_header "Keyboard Shortcuts & System Integration"

    if is_macos; then
        setup_macos_shortcuts
    elif is_kde_plasma; then
        setup_plasma_shortcuts
    fi

    # Create shortcuts documentation
    create_shortcuts_documentation
}

setup_macos_shortcuts() {
    print_info "Setting up macOS keyboard shortcuts..."

    # Global shortcuts for apps
    defaults write -g NSUserKeyEquivalents -dict-add "Open Kitty" "@~t"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Visual Studio Code" "@~c"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Finder" "@~f"
    defaults write -g NSUserKeyEquivalents -dict-add "Open Google Chrome" "@~b"

    # Mission Control shortcuts
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>18</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>19</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>123</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>124</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"

    print_info "macOS shortcuts configured:"
    print_info "  Cmd+Opt+T → Kitty Terminal"
    print_info "  Cmd+Opt+C → VS Code"
    print_info "  Cmd+Opt+F → Finder"
    print_info "  Cmd+Opt+B → Browser"
    print_info "  Ctrl+Up/Down/Left/Right → Mission Control"

    # Rectangle info
    if command_exists rectangle || [[ -d "/Applications/Rectangle.app" ]]; then
        print_info "Rectangle window management shortcuts:"
        print_info "  Ctrl+Opt+Left/Right → Tile window"
        print_info "  Ctrl+Opt+Enter → Maximize"
        print_info "  Ctrl+Opt+C → Center"
    fi
}

setup_plasma_shortcuts() {
    print_info "Setting up KDE Plasma 6 keyboard shortcuts..."

    # Use kwriteconfig6 if available (Plasma 6), fallback to kwriteconfig5
    local kwrite_cmd="kwriteconfig5"
    command_exists kwriteconfig6 && kwrite_cmd="kwriteconfig6"

    if command_exists "$kwrite_cmd"; then
        # Application shortcuts - use kwriteconfig with desktop file as group name
        "$kwrite_cmd" --file kglobalshortcutsrc --group "com.mitchellh.ghostty.desktop" --key _launch "Ctrl+Alt+T,Ctrl+Alt+T,Launch Ghostty"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "code.desktop" --key _launch "Ctrl+Alt+C,Ctrl+Alt+C,Launch VS Code"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "org.kde.dolphin.desktop" --key _launch "Ctrl+Alt+F,Ctrl+Alt+F,Launch Dolphin"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "google-chrome.desktop" --key _launch "Ctrl+Alt+B,Ctrl+Alt+B,Launch Chrome"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "org.kde.plasma-systemmonitor.desktop" --key _launch "Ctrl+Alt+M,Ctrl+Alt+M,Launch System Monitor"
        "$kwrite_cmd" --file kglobalshortcutsrc --group "rofi-launcher.desktop" --key _launch "Alt+Space,Alt+Space,Rofi Launcher"

        # Setup Rofi desktop files
        setup_kde_rofi_shortcuts

        # Window tiling (KDE defaults)
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Top" "Meta+Up,Meta+Up,Quick Tile Window to the Top"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Bottom" "Meta+Down,Meta+Down,Quick Tile Window to the Bottom"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Left" "Meta+Left,Meta+Left,Quick Tile Window to the Left"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Quick Tile Right" "Meta+Right,Meta+Right,Quick Tile Window to the Right"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Maximize" "Meta+PgUp,Meta+PgUp,Maximize Window"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Window Minimize" "Meta+PgDown,Meta+PgDown,Minimize Window"

        # Desktop switching
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Ctrl+F1,Ctrl+F1,Switch to Desktop 1"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Ctrl+F2,Ctrl+F2,Switch to Desktop 2"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Ctrl+F3,Ctrl+F3,Switch to Desktop 3"
        "$kwrite_cmd" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Ctrl+F4,Ctrl+F4,Switch to Desktop 4"

        # Reload KDE shortcuts daemon to apply changes
        # This is critical for shortcuts to take effect without logout
        if command_exists kquitapp6; then
            kquitapp6 kglobalaccel 2>/dev/null
            sleep 2
            # kglobalaccel auto-restarts via systemd, but we can force it
            systemctl --user restart plasma-kglobalaccel.service 2>/dev/null || kstart6 kglobalaccel6 2>/dev/null &
        elif command_exists kquitapp5; then
            kquitapp5 kglobalaccel 2>/dev/null
            sleep 2
            kstart5 kglobalaccel5 2>/dev/null &
        fi

        print_info "KDE Plasma shortcuts configured:"
        print_info "  F12        → Dropdown Terminal"
        print_info "  Ctrl+Alt+T → Terminal"
        print_info "  Ctrl+Alt+C → VS Code"
        print_info "  Ctrl+Alt+F → File Manager"
        print_info "  Alt+Space  → KRunner/Rofi"
        print_info "  Meta+Arrows → Window Tiling"
    fi

    # DISABLED: Rofi shortcuts info
    # # Rofi shortcuts info
    # if command_exists rofi && [[ -d "$HOME/.config/rofi/scripts" ]]; then
    #     print_info "Rofi launcher shortcuts available:"
    #     print_info "  Alt+Space → App launcher"
    #     print_info "  Alt+Shift+C → Clipboard history"
    #     print_info "  Alt+Shift+P → Power menu"
    #     print_info "  Alt+Shift+D → Developer menu"
    # fi
}

create_shortcuts_documentation() {
    print_info "Creating shortcuts documentation..."

    local doc_file="$HOME/.config/keyboard-shortcuts-reference.md"

    cat > "$doc_file" << 'EOF'
# Keyboard Shortcuts Reference

## Quick Access
This file contains all keyboard shortcuts configured by the dev setup.

### Platform-Specific Shortcuts

EOF

    if is_macos; then
        cat >> "$doc_file" << 'EOF'
#### macOS Shortcuts

**System**
- `Cmd+Space` → Raycast (app launcher)
- `Cmd+Opt+T` → Ghostty Terminal
- `Cmd+Opt+C` → VS Code
- `Cmd+Opt+V` → Clipboard History
- `Cmd+Opt+E` → Emoji Picker

**Window Management (Rectangle)**
- `Ctrl+Opt+Left` → Left half
- `Ctrl+Opt+Right` → Right half
- `Ctrl+Opt+Enter` → Maximize
- `Ctrl+Opt+Up` → Top half
- `Ctrl+Opt+Down` → Bottom half

**Mission Control**
- `Ctrl+Up` → Mission Control
- `Ctrl+Down` → Application Windows
- `Ctrl+Left/Right` → Switch Spaces

EOF
    elif is_kde_plasma; then
        cat >> "$doc_file" << 'EOF'
#### KDE Plasma Shortcuts

**Applications**
- `Ctrl+Alt+T` → Ghostty Terminal
- `Ctrl+Alt+C` → VS Code
- `Ctrl+Alt+F` → File Manager
- `Ctrl+Alt+B` → Browser
- `Ctrl+Alt+M` → System Monitor

**Launchers**
- `Alt+Space` → Rofi (app launcher)
- `Alt+F2` → KRunner
- `Alt+Shift+C` → Clipboard History
- `Alt+Shift+P` → Power Menu
- `Alt+Shift+D` → Developer Menu

**Window Management**
- `Meta+Left/Right` → Tile window
- `Meta+Up` → Maximize
- `Meta+Down` → Minimize
- `Alt+Tab` → Switch windows

**Virtual Desktops**
- `Ctrl+F1-F4` → Switch desktop
- `Ctrl+Shift+F1-F4` → Move window to desktop

EOF
    fi

    cat >> "$doc_file" << 'EOF'
### Terminal Shortcuts (Ghostty)

- `Ctrl+Shift+T` → New tab
- `Ctrl+Shift+N` → New window
- `Ctrl+Shift+W` → Close tab
- `Ctrl+Tab` → Next tab
- `Ctrl+Shift+Tab` → Previous tab
- `Ctrl+Shift+C` → Copy
- `Ctrl+Shift+V` → Paste

### Editor Shortcuts (VS Code)

- `Cmd/Ctrl+P` → Quick file open
- `Cmd/Ctrl+Shift+P` → Command palette
- `Cmd/Ctrl+B` → Toggle sidebar
- `Cmd/Ctrl+J` → Toggle terminal
- `F12` → Go to definition
- `Shift+F12` → Find references

### Git (lazygit)

- `lg` → Open lazygit
- `Space` → Stage/unstage
- `c` → Commit
- `p` → Push
- `P` → Pull

For complete shortcuts documentation, see the docs/shortcuts/ directory in your dev-setup repository.
EOF

    print_success "Shortcuts reference created at: $doc_file"
}

# ==========================================
# Post-Install Verification
# ==========================================

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
    [[ -f "$HOME/.zshrc" ]] && print_success "~/.zshrc exists" || { print_error "~/.zshrc missing"; errors=$((errors + 1)); }
    [[ -f "$HOME/.gitconfig" ]] && print_success "~/.gitconfig exists" || { print_error "~/.gitconfig missing"; errors=$((errors + 1)); }
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

# ==========================================
# Main Execution
# ==========================================

main() {
    print_header "Developer Environment Setup"
    print_info "Platform: $(get_platform)"
    if is_macos; then
        print_info "macOS version: $(get_macos_version)"
    elif is_arch_linux; then
        print_info "Arch Linux detected"
        is_cachyos && print_info "CachyOS detected"
        is_endeavouros && print_info "EndeavourOS detected"
        is_kde_plasma && print_info "KDE Plasma detected"
    fi

    # Run all setup functions
    preflight_checks
    setup_mise
    setup_system_optimizations
    setup_terminal_and_shell
    setup_git
    setup_development_tools
    setup_productivity_apps
    setup_gaming_network
    setup_game_development
    setup_cachyos_tuning
    setup_advanced_tools
    # DISABLED: Keyboard shortcuts - let user configure manually
    # setup_keyboard_shortcuts

    # Verify installation
    verify_installation

    print_header "Setup Complete!"
    echo "Your Web/Rust/C++ development environment is ready!"
    echo
    echo "What's installed:"
    echo "  - Node.js, Bun for JavaScript/TypeScript development"
    echo "  - Rust with cargo tools for systems programming"
    echo "  - C++ with CMake, Ninja, and modern toolchain"
    echo "  - Docker/Colima for containerization"
    echo "  - Full CLI toolkit (ripgrep, fzf, bat, eza, zoxide, etc.)"
    echo "  - Gaming tools (Steam, Lutris, Wine on Linux)"
    echo "  - Multiplayer hosting: firewall rules + gamenet diagnostics"
    echo "  - Productivity tools (Slack, Discord, 1Password)"
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: exec zsh)"
    echo "  2. Add SSH key to GitHub: gh ssh-key add ~/.ssh/id_ed25519.pub"
    echo "  3. Test Docker: docker run hello-world"
    is_arch_linux && echo "  4. Reboot for gaming optimizations to take effect"
    echo
    echo "Useful commands:"
    echo "  - cheat       : Show all aliases and shortcuts"
    echo "  - fo          : Fuzzy find and open files"
    echo "  - fcd         : Fuzzy find directories (zoxide)"
    echo "  - frg <term>  : Ripgrep with fzf preview"
    echo "  - lg          : Lazygit"
    echo "  - y           : Yazi file manager"
    echo "  - gamenet check <port> : Diagnose multiplayer connectivity"
    echo
    print_info "Happy coding!"

    # Ask to reboot
    echo
    print_info "A reboot is recommended to apply all changes (Docker group, KDE shortcuts, etc.)"
    echo
    read -p "Would you like to reboot now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Rebooting in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        sudo reboot
    else
        print_info "Remember to reboot later for all changes to take effect."
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            echo "Usage: $0"
            echo ""
            echo "This script sets up a complete development environment."
            echo "No options are required - just run ./install.sh"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run $0 --help for usage"
            exit 1
            ;;
    esac
done

# Start the script
main
