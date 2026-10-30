#!/usr/bin/env bash
# Cross-Platform Developer Setup Script
# Supports macOS and Arch Linux (EndeavourOS, CachyOS)
#
# Usage: ./install.sh [--yes] [--only STEPS] [--skip STEPS] [--doctor] [--help]
#
# This script is designed to be:
# - Idempotent (safe to run multiple times)
# - Non-destructive (backs up existing configs)
# - Reversible (documents how to undo changes)

set -Eeuo pipefail

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

INSTALL_LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dev-setup/install-$(date +%Y%m%d-%H%M%S).log"

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
# shellcheck source=modules/packages.sh
source "$SCRIPT_DIR/modules/packages.sh"
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

trap cleanup EXIT
trap 'error_handler "$LINENO" "$?" "${BASH_SOURCE[0]}"' ERR

# Step name for --only and --skip, and the function that runs it, in order
STEPS=(
    "preflight:preflight_checks"
    "mise:setup_mise"
    "dotfiles:setup_dotfiles"
    "packages:setup_packages"
    "system:setup_system_optimizations"
    "terminal:setup_terminal_and_shell"
    "git:setup_git"
    "dev:setup_development_tools"
    "apps:setup_productivity_apps"
    "gaming-network:setup_gaming_network"
    "gamedev:setup_game_development"
    "cachyos:setup_cachyos_tuning"
    "media:setup_advanced_tools"
    "bolt:setup_bolt"
    "verify:verify_installation"
)
ONLY_STEPS=""
SKIP_STEPS=""

usage() {
    cat <<EOF
Usage: $0 [options]

Sets up macOS or Arch Linux for development. Safe to run again: dotfiles are
links, packages already present are skipped, answers are remembered.

Options:
  -y, --yes          ask nothing; use saved answers, then defaults
  --reconfigure      ask the setup questions again
  --only STEPS       run only these steps (comma separated)
  --skip STEPS       run every step except these
  --list             list the steps
  --doctor           check this machine against the repo and change nothing
  -h, --help         show this help

Answers are saved in $CHOICES_FILE. GIT_NAME, GIT_EMAIL, INSTALL_GAMING,
INSTALL_GAMEDEV and INSTALL_AGENT_KIT in the environment override them.
EOF
}

step_known() {
    local name="$1" entry
    for entry in "${STEPS[@]}"; do
        [[ "${entry%%:*}" == "$name" ]] && return 0
    done
    return 1
}

check_step_list() {
    local list="$1" name
    local IFS=,
    for name in $list; do
        step_known "$name" || { print_error "Unknown step '$name' (see --list)"; exit 1; }
    done
}

step_selected() {
    local name="$1"
    if [[ -n "$ONLY_STEPS" ]]; then
        [[ ",$ONLY_STEPS," == *",$name,"* ]] || return 1
    fi
    [[ ",$SKIP_STEPS," != *",$name,"* ]]
}

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

    keep_sudo_alive
    # preflight installs Homebrew, but --only may skip it
    if is_macos; then
        load_brew_env || true
    fi
    # The answers feed several steps, so they are loaded even under --only
    collect_choices

    local entry
    for entry in "${STEPS[@]}"; do
        if step_selected "${entry%%:*}"; then
            "${entry#*:}"
        fi
    done
    [[ -z "$ONLY_STEPS" ]] || return 0

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
    local reboot=""
    can_ask && ask_yes_no reboot "Would you like to reboot now?" false
    if [[ "$reboot" == true ]]; then
        print_info "Rebooting in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        sudo reboot
    else
        print_info "Remember to reboot later for all changes to take effect."
    fi
}

RUN_DOCTOR=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) ASSUME_YES=true ;;
        --reconfigure) RECONFIGURE=true ;;
        --only) ONLY_STEPS="${2:?--only needs a list of steps}"; shift ;;
        --skip) SKIP_STEPS="${2:?--skip needs a list of steps}"; shift ;;
        --list)
            for entry in "${STEPS[@]}"; do echo "${entry%%:*}"; done
            exit 0
            ;;
        --doctor) RUN_DOCTOR=true ;;
        -h|--help) usage; exit 0 ;;
        *)
            echo "Unknown option: $1"
            echo "Run $0 --help for usage"
            exit 1
            ;;
    esac
    shift
done
check_step_list "$ONLY_STEPS"
check_step_list "$SKIP_STEPS"

if [[ "$RUN_DOCTOR" == true ]]; then
    if run_doctor; then exit 0; else exit 1; fi
fi

ensure_directory "$(dirname "$INSTALL_LOG")"
exec > >(tee -a "$INSTALL_LOG") 2>&1
print_info "Logging to $INSTALL_LOG"
INSTALLING=true
main
# cleanup lists what failed
[[ ${#FAILED_PACKAGES[@]} -eq 0 ]] || exit 1
