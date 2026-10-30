# shellcheck shell=bash
# Sourced by install.sh.

GIT_NAME=""
GIT_EMAIL=""
INSTALL_GAMING=false
INSTALL_GAMEDEV=false
INSTALL_AGENT_KIT=true

# Every question is asked here, before the long installs, so the rest of the
# run needs no attention.
collect_choices() {
    print_header "Setup Questions"

    GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -z "$GIT_NAME" ]]; then
        read -r -p "Enter your name for Git commits: " GIT_NAME
        if [[ -z "$GIT_NAME" ]]; then
            GIT_NAME="Developer"
            print_warning "Using default name: Developer"
        fi
    fi

    if [[ -z "$GIT_EMAIL" ]]; then
        read -r -p "Enter your email for Git commits: " GIT_EMAIL
        if [[ -z "$GIT_EMAIL" ]]; then
            GIT_EMAIL="developer@example.com"
            print_warning "Using default email: developer@example.com"
        fi
    fi

    if is_linux; then
        read -p "Install gaming packages (Steam, Lutris, Wine, MangoHud)? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_GAMING=true
    fi

    read -p "Install game development tools (engines, Vulkan SDK, profilers)? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_GAMEDEV=true

    read -p "Set up agent-kit (Claude Code instructions, hooks and skills)? [Y/n] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] && INSTALL_AGENT_KIT=false

    setup_ssh_key
    print_success "Answers recorded. The rest of the install runs unattended."
}
