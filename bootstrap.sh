#!/bin/bash
# Entry point for a machine with nothing installed yet:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/salamaashoush/dev-setup/main/bootstrap.sh)"
#
# macOS ships bash 3.2 and no git, so this file sticks to bash 3.2 syntax. It
# installs Homebrew (which brings the Command Line Tools and git) and a current
# bash, fetches the repository, then hands over to install.sh.
#
# Use `bash -c "$(curl ...)"` rather than `curl ... | bash`: the installer
# prompts, and a piped script has no terminal on stdin to prompt from.

set -euo pipefail

REPO="${DEV_SETUP_REPO:-salamaashoush/dev-setup}"
DEST="${DEV_SETUP_DIR:-$HOME/Workspace/dev-setup}"

say() { printf '\033[0;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[0;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

[ -t 0 ] || die "stdin is not a terminal. Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh)\""

case "$OSTYPE" in
    darwin*|linux-gnu*) ;;
    *) die "Unsupported platform: $OSTYPE" ;;
esac

say "Caching sudo credentials for the rest of the install"
sudo -v
# Refresh the timestamp until this process, or the install.sh it execs into, exits.
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

find_brew() {
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

if [[ "$OSTYPE" == darwin* ]]; then
    if ! brew_bin=$(find_brew); then
        say "Installing Homebrew and the Xcode Command Line Tools"
        # NONINTERACTIVE skips Homebrew's "press RETURN" prompt; the sudo
        # timestamp cached above covers its privileged steps.
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew_bin=$(find_brew) || die "Homebrew installation failed"
    fi
    eval "$("$brew_bin" shellenv)"
    brew list bash >/dev/null 2>&1 || brew install bash
    next_bash="$(brew --prefix)/bin/bash"
else
    command -v pacman >/dev/null || die "Only macOS and Arch-based Linux are supported"
    command -v git >/dev/null || sudo pacman -S --needed --noconfirm git
    next_bash="$(command -v bash)"
fi

clone_repo() {
    say "Cloning $REPO into $DEST"
    if GIT_TERMINAL_PROMPT=0 git clone "https://github.com/$REPO.git" "$DEST" 2>/dev/null; then
        return 0
    fi
    say "Anonymous clone failed (private repository?); signing in to GitHub"
    if ! command -v gh >/dev/null; then
        if [[ "$OSTYPE" == darwin* ]]; then
            brew install gh
        else
            sudo pacman -S --needed --noconfirm github-cli
        fi
    fi
    gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web
    gh repo clone "$REPO" "$DEST"
}

self="${BASH_SOURCE[0]:-}"
if [ -n "$self" ] && [ -f "$(dirname "$self")/install.sh" ]; then
    repo_dir="$(cd "$(dirname "$self")" && pwd)"
elif [ -f "$DEST/install.sh" ]; then
    repo_dir="$DEST"
else
    clone_repo
    repo_dir="$DEST"
fi

say "Running $repo_dir/install.sh"
exec "$next_bash" "$repo_dir/install.sh" ${1+"$@"}
