# shellcheck shell=bash
# Sourced by install.sh.

# Answers are saved after the first run so later runs ask nothing. An
# environment variable beats a saved answer, which beats asking.
CHOICES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dev-setup/choices"
ASSUME_YES=false
RECONFIGURE=false

GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"
INSTALL_GAMING="${INSTALL_GAMING:-}"
INSTALL_GAMEDEV="${INSTALL_GAMEDEV:-}"
INSTALL_AGENT_KIT="${INSTALL_AGENT_KIT:-}"

CHOICE_KEYS=(GIT_NAME GIT_EMAIL INSTALL_GAMING INSTALL_GAMEDEV INSTALL_AGENT_KIT)

can_ask() {
    [[ "$ASSUME_YES" != true && -t 0 ]]
}

# Read as KEY=value lines rather than sourced, so the file cannot run code
load_choices() {
    [[ -f "$CHOICES_FILE" && "$RECONFIGURE" != true ]] || return 0
    local key value known
    while IFS='=' read -r key value; do
        for known in "${CHOICE_KEYS[@]}"; do
            if [[ "$key" == "$known" && -z "${!key}" ]]; then
                printf -v "$key" '%s' "$value"
            fi
        done
    done < "$CHOICES_FILE"
}

save_choices() {
    ensure_directory "$(dirname "$CHOICES_FILE")"
    local key
    for key in "${CHOICE_KEYS[@]}"; do
        printf '%s=%s\n' "$key" "${!key}"
    done > "$CHOICES_FILE"
}

ask_text() {
    local var="$1" question="$2" fallback="$3" reply=""
    [[ -n "${!var}" ]] && return 0
    can_ask && read -r -p "$question " reply
    if [[ -z "$reply" ]]; then
        reply="$fallback"
        print_warning "Using $fallback"
    fi
    printf -v "$var" '%s' "$reply"
}

ask_yes_no() {
    local var="$1" question="$2" default="$3" reply="" hint="[y/N]"
    [[ -n "${!var}" ]] && return 0
    [[ "$default" == true ]] && hint="[Y/n]"
    if can_ask; then
        read -r -p "$question $hint " -n 1 reply
        echo
    fi
    case "$reply" in
        [Yy]) printf -v "$var" true ;;
        [Nn]) printf -v "$var" false ;;
        *) printf -v "$var" '%s' "$default" ;;
    esac
}

# Every question is asked here, before the long installs, so the rest of the
# run needs no attention.
collect_choices() {
    print_header "Setup Questions"

    load_choices
    [[ -n "$GIT_NAME" ]] || GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
    [[ -n "$GIT_EMAIL" ]] || GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

    ask_text GIT_NAME "Enter your name for Git commits:" "Developer"
    ask_text GIT_EMAIL "Enter your email for Git commits:" "developer@example.com"
    if is_linux; then
        ask_yes_no INSTALL_GAMING "Install gaming packages (Steam, Lutris, Wine, MangoHud)?" false
    else
        INSTALL_GAMING=false
    fi
    ask_yes_no INSTALL_GAMEDEV "Install game development tools (engines, Vulkan SDK, profilers)?" false
    ask_yes_no INSTALL_AGENT_KIT "Set up agent-kit (Claude Code instructions, hooks and skills)?" true

    save_choices
    setup_ssh_key
    print_success "Answers saved to $CHOICES_FILE. The rest of the install runs unattended."
}
