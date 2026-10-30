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
# Bash Version Check
# ==========================================

if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
    for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
        if [[ -x "$candidate" ]] && "$candidate" -c '((BASH_VERSINFO[0] >= 4))'; then
            echo "Re-running with $candidate (Bash $BASH_VERSION is too old)..."
            exec "$candidate" "$0" ${1+"$@"}
        fi
    done
    if [[ "$OSTYPE" == darwin* ]]; then
        # Stock macOS: bootstrap.sh installs Homebrew and a current bash, then runs this script again
        exec /bin/bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap.sh" ${1+"$@"}
    fi
    echo "Error: This script requires Bash 4.0 or higher."
    echo "Current version: $BASH_VERSION"
    exit 1
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

# shellcheck source=lib/core.sh
source "$SCRIPT_DIR/lib/core.sh"
# shellcheck source=lib/links.sh
source "$SCRIPT_DIR/lib/links.sh"
# shellcheck source=modules/preflight.sh
source "$SCRIPT_DIR/modules/preflight.sh"
# shellcheck source=modules/system.sh
source "$SCRIPT_DIR/modules/system.sh"
# shellcheck source=modules/mise.sh
source "$SCRIPT_DIR/modules/mise.sh"
# shellcheck source=modules/dotfiles.sh
source "$SCRIPT_DIR/modules/dotfiles.sh"
# shellcheck source=modules/terminal.sh
source "$SCRIPT_DIR/modules/terminal.sh"
# shellcheck source=modules/choices.sh
source "$SCRIPT_DIR/modules/choices.sh"
# shellcheck source=modules/git.sh
source "$SCRIPT_DIR/modules/git.sh"
# shellcheck source=modules/dev-tools.sh
source "$SCRIPT_DIR/modules/dev-tools.sh"
# shellcheck source=modules/apps.sh
source "$SCRIPT_DIR/modules/apps.sh"
# shellcheck source=modules/gaming.sh
source "$SCRIPT_DIR/modules/gaming.sh"
# shellcheck source=modules/advanced.sh
source "$SCRIPT_DIR/modules/advanced.sh"
# shellcheck source=modules/bolt.sh
source "$SCRIPT_DIR/modules/bolt.sh"
# shellcheck source=modules/shortcuts.sh
source "$SCRIPT_DIR/modules/shortcuts.sh"
# shellcheck source=modules/verify.sh
source "$SCRIPT_DIR/modules/verify.sh"

# Track if we're in the middle of a critical section
CRITICAL_SECTION=false

trap cleanup EXIT
trap 'error_handler ${LINENO} $?' ERR

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

    # Every path below is absolute. Working from $HOME keeps a project mise.toml
    # in the caller's directory (this repo has one) from making each mise-managed
    # tool the script runs stop at an untrusted-config error.
    cd "$HOME"

    # Run all setup functions
    keep_sudo_alive
    preflight_checks
    collect_choices
    setup_mise
    setup_dotfiles
    setup_system_optimizations
    setup_terminal_and_shell
    setup_git
    setup_development_tools
    setup_productivity_apps
    setup_gaming_network
    setup_game_development
    setup_cachyos_tuning
    setup_advanced_tools
    setup_bolt
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
    echo "  - Claude Code and the herdr agent multiplexer"
    echo "  - Runtimes, CLI tools, and Claude Code are managed by mise: 'mise up' upgrades them"
    echo "  - Gaming tools (Steam, Lutris, Wine on Linux)"
    echo "  - Multiplayer hosting: firewall rules + gamenet diagnostics"
    echo "  - Productivity tools (Slack, Discord, 1Password)"
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: exec zsh)"
    echo "  2. Sign in to GitHub and add your SSH key: gh auth login && gh ssh-key add ~/.ssh/id_ed25519.pub"
    echo "  3. Sign in to Claude Code: claude"
    echo "  4. Test Docker: docker run hello-world"
    is_arch_linux && echo "  5. Reboot for gaming optimizations to take effect"
    echo
    echo "Useful commands:"
    echo "  - cheat       : Show all aliases and shortcuts"
    echo "  - fo          : Fuzzy find and open files"
    echo "  - fcd         : Fuzzy find directories (zoxide)"
    echo "  - frg <term>  : Ripgrep with fzf preview"
    echo "  - lg          : Lazygit"
    echo "  - y           : Yazi file manager"
    echo "  - herdr       : Agent multiplexer (prefix Ctrl+Space)"
    echo "  - gamenet check <port> : Diagnose multiplayer connectivity"
    echo
    print_info "Happy coding!"

    # Ask to reboot. macOS picks everything up in a new terminal.
    is_linux || return 0
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
