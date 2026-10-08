#!/usr/bin/env bash
# Cross-platform aliases and functions
# Sourced by ~/.config/shell/aliases.sh
#
# IMPORTANT: This file does NOT override core system commands (ls, cat, du, df, etc.)
# to ensure scripts and system tools continue to work correctly.
# Instead, we provide new command names for modern alternatives.
#
# To use original commands in scripts, prefix with backslash: \ls, \cat, \du

# ===========================================
# Modern CLI Tool Aliases (Non-Breaking)
# ===========================================
# These do NOT override standard commands - scripts will work normally

# File listing (eza) - use 'e' prefix or 'l' variants
if command -v eza &>/dev/null; then
    # Primary aliases - don't shadow 'ls'
    alias e='eza --icons --git --group-directories-first'
    alias el='eza -l --icons --git --header --group-directories-first'
    alias ea='eza -la --icons --git --header --group-directories-first'
    alias et='eza --tree --icons --git --level=2 --group-directories-first'
    alias eta='eza --tree --icons --git --level=3 -a --group-directories-first'
    alias e1='eza -1 --icons --group-directories-first'

    # 'l' variants (common convention, doesn't break anything)
    alias ll='eza -l --icons --git --header --group-directories-first'
    alias la='eza -la --icons --git --header --group-directories-first'
    alias lt='eza --tree --icons --git --level=2 --group-directories-first'
    alias l='eza -1 --icons --group-directories-first'

    # Specialized views
    alias lss='eza -l --icons --git --header --sort=size --reverse'
    alias lsd='eza -lD --icons'  # directories only
    alias lsf='eza -lf --icons --git'  # files only
fi

# Cat with syntax highlighting (bat) - use 'b' prefix
if command -v bat &>/dev/null; then
    # Primary aliases - don't shadow 'cat' or 'less'
    alias b='bat --style=auto --paging=never'
    alias bp='bat --style=auto --paging=always'  # bat with pager
    alias bcat='bat --style=plain --paging=never'  # plain output like cat
    alias bfull='bat --style=full'  # full bat with line numbers, grid

    # Bat config via environment
    export BAT_THEME="tokyonight_storm"
    export BAT_STYLE="numbers,changes,header"

    # Use bat for man pages (this is safe - man handles it)
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"

    # batgrep - grep with bat highlighting (new command, safe)
    if command -v rg &>/dev/null; then
        batgrep() {
            rg --color=never --line-number "$@" | fzf --ansi --preview 'bat --color=always --highlight-line {2} {1}' --preview-window '+{2}/2'
        }
    fi

    # batdiff - diff with bat (new command, safe)
    batdiff() {
        git diff --name-only --relative --diff-filter=d | xargs bat --diff
    }
fi

# Directory navigation (these are safe - new commands)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ===========================================
# System Monitoring (Non-Breaking)
# ===========================================
# Use new names instead of overriding top, du, df, ping

# btop - modern system monitor (use 'bt' not 'top')
command -v btop &>/dev/null && alias bt='btop'

# procs - modern ps (use 'pss' not 'ps')
command -v procs &>/dev/null && alias pss='procs'

# dust - modern du (use 'dust' directly, don't alias 'du')
# du stays as standard du for scripts

# duf - modern df (use 'duf' directly, don't alias 'df')
# df stays as standard df for scripts

# gping - graphical ping (use 'gp' not 'ping')
command -v gping &>/dev/null && alias gpi='gping'

# ===========================================
# Git Aliases (Safe - 'g' prefix)
# ===========================================

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcam='git commit --amend -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gs='git status'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gsc='git switch -c'
alias gm='git merge'
alias gr='git rebase'
alias gri='git rebase -i'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gsp='git stash pop'
alias gss='git stash save'
alias gsl='git stash list'

# Git with lazygit
alias lg='lazygit'

# ===========================================
# Docker (Safe - 'd' prefix)
# ===========================================

alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dr='docker run --rm -it'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dbd='docker build'
alias dex='docker exec -it'
alias dl='docker logs -f'
alias dsp='docker system prune -f'
alias dv='docker volume'
alias dn='docker network'

# Docker database helpers
db-start() {
    local db_type="${1:-postgres}"
    local name="${2:-$db_type}"
    local port=""
    local password="devpass"

    case "$db_type" in
        postgres|pg)
            port="${3:-5432}"
            echo "Starting PostgreSQL '$name' on port $port..."
            docker run -d --name "$name" \
                -e POSTGRES_PASSWORD="$password" \
                -p "$port:5432" \
                -v "${name}_data:/var/lib/postgresql/data" \
                postgres:16-alpine
            echo "Connection: postgresql://postgres:$password@localhost:$port/postgres"
            ;;
        mysql)
            port="${3:-3306}"
            echo "Starting MySQL '$name' on port $port..."
            docker run -d --name "$name" \
                -e MYSQL_ROOT_PASSWORD="$password" \
                -p "$port:3306" \
                -v "${name}_data:/var/lib/mysql" \
                mysql:8
            echo "Connection: mysql://root:$password@localhost:$port"
            ;;
        redis)
            port="${3:-6379}"
            echo "Starting Redis '$name' on port $port..."
            docker run -d --name "$name" \
                -p "$port:6379" \
                -v "${name}_data:/data" \
                redis:alpine
            echo "Connection: redis://localhost:$port"
            ;;
        mongo|mongodb)
            port="${3:-27017}"
            echo "Starting MongoDB '$name' on port $port..."
            docker run -d --name "$name" \
                -p "$port:27017" \
                -v "${name}_data:/data/db" \
                mongo:7
            echo "Connection: mongodb://localhost:$port"
            ;;
        *)
            echo "Usage: db-start <postgres|mysql|redis|mongo> [name] [port]"
            return 1
            ;;
    esac
}

db-stop() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo "This will stop containers named: postgres, mysql, redis, mongo"
        read -r -p "Continue? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "Stopping database containers..."
            docker stop postgres mysql redis mongo 2>/dev/null || true
        else
            echo "Cancelled."
        fi
    else
        docker stop "$name" 2>/dev/null && docker rm "$name" 2>/dev/null
    fi
}

db-shell() {
    local name="${1:?Container name required}"
    local image
    image=$(docker inspect "$name" --format='{{.Config.Image}}' 2>/dev/null)

    case "$image" in
        *postgres*) docker exec -it "$name" psql -U postgres ;;
        *mysql*) docker exec -it "$name" mysql -uroot -pdevpass ;;
        *redis*) docker exec -it "$name" redis-cli ;;
        *mongo*) docker exec -it "$name" mongosh ;;
        *) docker exec -it "$name" sh ;;
    esac
}

# Docker service management
if [[ "$OSTYPE" == "darwin"* ]] && command -v colima &>/dev/null; then
    alias docker-start='colima start --cpu 4 --memory 8 --disk 100 --vm-type vz --mount-type virtiofs'
    alias docker-stop='colima stop'
    alias docker-status='colima status'
elif command -v systemctl &>/dev/null; then
    alias docker-start='sudo systemctl start docker'
    alias docker-stop='sudo systemctl stop docker'
    alias docker-status='systemctl status docker --no-pager'
fi

# ===========================================
# Node.js / JavaScript (Safe - short prefixes)
# ===========================================

alias ni='npm install'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'

alias pni='pnpm install'
alias pnr='pnpm run'
alias pnd='pnpm dev'
alias pnb='pnpm build'

alias bni='bun install'
alias bnr='bun run'
alias bnd='bun dev'
alias bnb='bun build'

# ===========================================
# Python (Safe)
# ===========================================

alias py='python3'
alias pyp='uv pip'
alias pyvenv='uv venv'
alias pyactivate='source .venv/bin/activate'

# ===========================================
# Claude CLI
# ===========================================

alias yolo='claude --dangerously-skip-permissions'

# ===========================================
# herdr (Agent Multiplexer)
# ===========================================

alias hr='herdr'
alias hrl='herdr session list'
alias hra='herdr session attach'
alias hrk='herdr session stop'

# Attach to a named session, creating it if needed
hrs() {
    herdr --session "${1:-dev}"
}

# ===========================================
# FZF-Powered Functions (New commands - safe)
# ===========================================

# fzf file opener with preview (uses bat)
fo() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}' \
           --preview-window=right:60%:wrap \
           --bind='ctrl-/:toggle-preview')
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# fzf directory jumper with preview (uses eza + zoxide)
fcd() {
    local dir
    if command -v zoxide &>/dev/null; then
        dir=$(zoxide query -l | fzf --preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null' \
              --preview-window=right:50%)
    else
        dir=$(fd --type d --hidden --follow --exclude .git | \
              fzf --preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null' \
              --preview-window=right:50%)
    fi
    [[ -n "$dir" ]] && { cd "$dir" || return; }
}

# fzf ripgrep integration - search content and open in editor
frg() {
    local file line
    read -r file line <<<"$(rg --line-number --no-heading --color=always "${@:-}" | \
        fzf --ansi --delimiter=: \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' \
            --preview-window='right:60%:+{2}/2' | \
        awk -F: '{print $1, $2}')"
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file" "+$line"
}

# fzf git log browser
fgl() {
    git log --oneline --color=always | \
        fzf --ansi --preview 'git show --color=always {1}' \
            --preview-window=right:60%:wrap \
            --bind='enter:execute(git show --color=always {1} | less -R)'
}

# fzf git branch switcher
fgb() {
    local branch
    branch=$(git branch -a --color=always | grep -v HEAD | \
             fzf --ansi --preview 'git log --oneline --graph --color=always {1} | head -50' \
                 --preview-window=right:50% | \
             sed 's/^[* ]*//' | sed 's/remotes\/origin\///')
    [[ -n "$branch" ]] && git checkout "$branch"
}

# fzf process killer
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill process]' | awk '{print $2}')
    [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-9}
}

# fzf docker container selector
fdc() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf -m --header='[docker container]' | awk '{print $1}')
    [[ -n "$cid" ]] && echo "$cid"
}

# ===========================================
# Utility Functions (New commands - safe)
# ===========================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && { cd "$1" || return; }
}

# Extract archives
extract() {
    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1" ;;
        *.zst)     unzstd "$1" ;;
        *) echo "'$1' cannot be extracted" ;;
    esac
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 is required but not installed"
        return 1
    fi
    python3 -m http.server "$port"
}

# Git clone and cd
gclone() {
    git clone "$1" && { cd "$(basename "$1" .git)" || return; }
}

# Kill process on port
killport() {
    local port="${1:?Port number required}"
    local pids
    pids=$(lsof -ti :"$port" 2>/dev/null)
    if [[ -n "$pids" ]]; then
        echo "Killing processes on port $port: $pids"
        kill -9 $pids
    else
        echo "No process found on port $port"
    fi
}

# Weather
weather() {
    curl -s "wttr.in/${1:-}"
}

# Public IP
myip() {
    curl -s https://ipinfo.io/ip && echo
}

# Yazi file manager with cd-on-quit
y() {
    if ! command -v yazi &>/dev/null; then
        echo "Error: yazi is not installed"
        return 1
    fi
    local tmp
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return 1
    # Ensure cleanup on exit
    trap 'rm -f "$tmp"' EXIT
    yazi "$@" --cwd-file="$tmp"
    if [[ -r "$tmp" ]]; then
        local cwd
        cwd="$(<"$tmp")"
        [[ -n "$cwd" && "$cwd" != "$PWD" ]] && { cd "$cwd" || return; }
    fi
    rm -f "$tmp"
    trap - EXIT
}

# ===========================================
# Platform-Specific (Safe)
# ===========================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    alias o='open'
    alias finder='open -a Finder .'
    alias copy='pbcopy'

    # Homebrew (using 'br' prefix to avoid conflict with bun)
    alias bri='brew install'
    alias bric='brew install --cask'
    alias bru='brew uninstall'
    alias brs='brew search'
    alias brup='brew update && brew upgrade'
    alias brls='brew list'
    alias brdr='brew doctor'

    # macOS system
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    alias o='xdg-open'

    # Clipboard (Wayland)
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        alias copy='wl-copy'
    elif command -v xclip &>/dev/null; then
        alias copy='xclip -selection clipboard'
    fi

    # Arch Linux package management
    if command -v pacman &>/dev/null; then
        alias pi='sudo pacman -S'
        alias pu='sudo pacman -R'
        alias psearch='pacman -Ss'
        alias pup='sudo pacman -Syu'
        alias pls='pacman -Q'
        alias pinfo='pacman -Qi'
        alias pclean='sudo pacman -Sc'

        if command -v yay &>/dev/null; then
            alias yi='yay -S'
            alias yu='yay -R'
            alias ysearch='yay -Ss'
            alias yup='yay -Syu'
            alias yls='yay -Q'
        fi
    fi

    # Systemd
    alias sc='sudo systemctl'
    alias scu='systemctl --user'
    alias jc='journalctl'
    alias jcu='journalctl --user'
fi

# ===========================================
# System Cleanup (New command - safe)
# ===========================================

dev-cleanup() {
    echo "Cleaning up development caches..."

    # Package managers
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew cleanup 2>/dev/null || true
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sc --noconfirm 2>/dev/null || true
    fi

    # Development caches
    npm cache clean --force 2>/dev/null || true
    pnpm store prune 2>/dev/null || true
    uv cache clean 2>/dev/null || true
    cargo cache -a 2>/dev/null || true

    # Docker
    docker system prune -f 2>/dev/null || true

    echo "Cleanup complete!"
}

# ===========================================
# Project Templates (if available)
# ===========================================

[[ -f "$HOME/.config/shell/project-templates.sh" ]] && source "$HOME/.config/shell/project-templates.sh"

# ===========================================
# Cheatsheet Command
# ===========================================

cheat() {
    local section="${1:-all}"

    case "$section" in
        files|f)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                     FILE OPERATIONS                           │
├───────────────────────────────────────────────────────────────┤
│  LISTING (eza)                                                │
│    e         eza with icons & git                             │
│    el        eza long format                                  │
│    ea        eza all files (hidden)                           │
│    et        eza tree view (2 levels)                         │
│    ll/la/lt  same as el/ea/et                                 │
│    lss       sort by size                                     │
│    lsd       directories only                                 │
│    lsf       files only                                       │
│                                                               │
│  VIEWING (bat)                                                │
│    b         bat (syntax highlighted)                         │
│    bp        bat with pager                                   │
│    bcat      bat plain (like cat)                             │
│    bfull     bat with all decorations                         │
│                                                               │
│  SEARCHING                                                    │
│    rg        ripgrep (fast grep)                              │
│    sg        ast-grep (structural search)                     │
│    fd        fd (fast find)                                   │
│    fzf       fuzzy finder                                     │
│                                                               │
│  NAVIGATION                                                   │
│    z <dir>   zoxide smart jump                                │
│    zi        zoxide interactive                               │
│    y         yazi file manager                                │
│    ../.../   go up directories                                │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        git|g)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                       GIT COMMANDS                            │
├───────────────────────────────────────────────────────────────┤
│  BASICS                                                       │
│    g         git                                              │
│    gs        git status                                       │
│    ga        git add                                          │
│    gaa       git add --all                                    │
│    gc        git commit                                       │
│    gcm       git commit -m "msg"                              │
│    gca       git commit --amend                               │
│                                                               │
│  BRANCHES                                                     │
│    gb        git branch                                       │
│    gco       git checkout                                     │
│    gcb       git checkout -b                                  │
│    gsw       git switch                                       │
│    gsc       git switch -c                                    │
│    gm        git merge                                        │
│                                                               │
│  REMOTE                                                       │
│    gp        git push                                         │
│    gpf       git push --force-with-lease                      │
│    gpl       git pull                                         │
│    gf        git fetch                                        │
│                                                               │
│  HISTORY                                                      │
│    gl        git log (20 commits)                             │
│    gla       git log --all                                    │
│    gd        git diff                                         │
│    gds       git diff --staged                                │
│                                                               │
│  STASH                                                        │
│    gst       git stash                                        │
│    gsp       git stash pop                                    │
│    gsl       git stash list                                   │
│                                                               │
│  TOOLS                                                        │
│    lg        lazygit (TUI)                                    │
│    gclone    git clone + cd                                   │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        docker|d)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                     DOCKER COMMANDS                           │
├───────────────────────────────────────────────────────────────┤
│  BASICS                                                       │
│    d         docker                                           │
│    dc        docker compose                                   │
│    dps       docker ps                                        │
│    dpsa      docker ps -a                                     │
│    di        docker images                                    │
│                                                               │
│  COMPOSE                                                      │
│    dcu       docker compose up -d                             │
│    dcd       docker compose down                              │
│    dcl       docker compose logs -f                           │
│                                                               │
│  CONTAINERS                                                   │
│    dr        docker run --rm -it                              │
│    dex       docker exec -it                                  │
│    dl        docker logs -f                                   │
│    dsp       docker system prune -f                           │
│                                                               │
│  DATABASE HELPERS                                             │
│    db-start postgres [name] [port]                            │
│    db-start mysql [name] [port]                               │
│    db-start redis [name] [port]                               │
│    db-start mongo [name] [port]                               │
│    db-stop [name]                                             │
│    db-shell <name>                                            │
│                                                               │
│  SERVICE                                                      │
│    docker-start   start docker daemon                         │
│    docker-stop    stop docker daemon                          │
│    docker-status  check status                                │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        node|js|n)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                   NODE.JS / JAVASCRIPT                        │
├───────────────────────────────────────────────────────────────┤
│  NPM                                                          │
│    ni        npm install                                      │
│    nr        npm run                                          │
│    ns        npm start                                        │
│    nt        npm test                                         │
│    nb        npm run build                                    │
│    nd        npm run dev                                      │
│                                                               │
│  PNPM                                                         │
│    pni       pnpm install                                     │
│    pnr       pnpm run                                         │
│    pnd       pnpm dev                                         │
│    pnb       pnpm build                                       │
│                                                               │
│  BUN                                                          │
│    bni       bun install                                      │
│    bnr       bun run                                          │
│    bnd       bun dev                                          │
│    bnb       bun build                                        │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        fzf|fuzzy)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                    FZF FUNCTIONS                              │
├───────────────────────────────────────────────────────────────┤
│  FILE/DIR                                                     │
│    fo        fzf open file (with preview)                     │
│    fcd       fzf cd directory                                 │
│    Ctrl+T    fzf file selector                                │
│    Alt+C     fzf cd selector                                  │
│    Ctrl+R    fzf history search                               │
│                                                               │
│  GIT                                                          │
│    fgl       fzf git log browser                              │
│    fgb       fzf git branch switcher                          │
│                                                               │
│  SEARCH                                                       │
│    frg       fzf ripgrep (search + open)                      │
│    batgrep   ripgrep with bat preview                         │
│                                                               │
│  SYSTEM                                                       │
│    fkill     fzf process killer                               │
│    fdc       fzf docker container                             │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        system|sys|s)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                   SYSTEM COMMANDS                             │
├───────────────────────────────────────────────────────────────┤
│  MONITORING                                                   │
│    bt        btop (system monitor)                            │
│    pss       procs (process list)                             │
│    dust      disk usage (du alternative)                      │
│    duf       disk free (df alternative)                       │
│    gp        gping (graphical ping)                           │
│                                                               │
│  SYSTEMD (Linux)                                              │
│    sc        sudo systemctl                                   │
│    scu       systemctl --user                                 │
│    jc        journalctl                                       │
│    jcu       journalctl --user                                │
│                                                               │
│  PACKAGES (Arch)                                              │
│    pi        pacman -S (install)                              │
│    pu        pacman -R (remove)                               │
│    pup       pacman -Syu (update)                             │
│    psearch   pacman -Ss (search)                              │
│    yi/yup    yay variants                                     │
│                                                               │
│  CLIPBOARD                                                    │
│    copy      copy to clipboard                                │
│    pbpaste / wl-paste   paste from clipboard                  │
│                                                               │
│  MISC                                                         │
│    o         open (xdg-open/open)                             │
│    mkcd      mkdir + cd                                       │
│    extract   extract any archive                              │
│    serve     python http server                               │
│    killport  kill process on port                             │
│    myip      show public IP                                   │
│    weather   show weather                                     │
│    dev-cleanup  clean dev caches                              │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        python|py)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                      PYTHON                                   │
├───────────────────────────────────────────────────────────────┤
│    py          python3                                        │
│    pyp         uv pip                                         │
│    pyvenv      uv venv                                        │
│    pyactivate  source .venv/bin/activate                      │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        tools|t)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                   INSTALLED TOOLS                             │
├───────────────────────────────────────────────────────────────┤
│  MODERN REPLACEMENTS                                          │
│    eza       ls replacement (icons, git)                      │
│    bat       cat replacement (syntax hl)                      │
│    ripgrep   grep replacement (rg)                            │
│    fd        find replacement                                 │
│    dust      du replacement                                   │
│    duf       df replacement                                   │
│    btop      top replacement                                  │
│    procs     ps replacement                                   │
│    zoxide    cd replacement (z)                               │
│    gping     ping with graph                                  │
│                                                               │
│  CODE SEARCH                                                  │
│    rg        ripgrep - fast text search                       │
│    sg        ast-grep - structural code search                │
│    fzf       fuzzy finder                                     │
│                                                               │
│  DEV TOOLS                                                    │
│    lazygit   git TUI                                          │
│    yazi      file manager TUI                                 │
│    herdr     agent multiplexer                                │
│    starship  shell prompt                                     │
│    direnv    env per directory                                │
│    mise      version manager                                  │
│                                                               │
│  UTILITIES                                                    │
│    jq/yq     JSON/YAML processor                              │
│    xh        httpie alternative                               │
│    hyperfine benchmarking                                     │
│    tokei     code statistics                                  │
│    tldr      simplified man pages                             │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        herdr|hr|mux)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                     HERDR (Agent Multiplexer)                 │
├───────────────────────────────────────────────────────────────┤
│  STARTING                                                     │
│    herdr                     Launch or attach default session │
│    hrs <name>                Attach or create named session   │
│    hrl                       List sessions                    │
│    hra <name>                Attach to session                │
│    hrk <name>                Stop session                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  PREFIX  Ctrl+Space   (bindings follow tmux)                  │
│    ?          Help                                            │
│    d          Detach                                          │
│    q          Reload config                                   │
│    [          Copy mode                                       │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  PANES                                                        │
│    prefix h / Alt+Enter          Split horizontally           │
│    prefix v / Alt+Shift+Enter    Split vertically             │
│    prefix x / Alt+Esc            Close pane                   │
│    prefix z                      Zoom                         │
│    prefix ;                      Last pane                    │
│    Ctrl+Alt+Arrows               Focus pane                   │
│    Ctrl+Alt+Shift+Arrows         Resize pane                  │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  TABS                                                         │
│    prefix c                      New tab                      │
│    prefix r                      Rename tab                   │
│    prefix k                      Close tab                    │
│    prefix 1-9 / Alt+1-9          Go to tab                    │
│    prefix p,n / Alt+Left,Right   Previous/next tab            │
│    Alt+Shift+Left,Right          Move tab                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  WORKSPACES                                                   │
│    prefix Shift+c                New workspace                │
│    prefix Shift+r                Rename workspace             │
│    prefix Shift+k                Close workspace              │
│    prefix Shift+p,n              Previous/next workspace      │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        kde|shortcuts|keys|k)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                   KDE GLOBAL SHORTCUTS                        │
├───────────────────────────────────────────────────────────────┤
│  TERMINALS                                                    │
│    F12             Ghostty dropdown (Quake-style)             │
│    Ctrl+Alt+T      Open Ghostty terminal                      │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  LAUNCHERS                                                    │
│    Alt+Space       Rofi app launcher                          │
│    Alt+F2          KRunner                                    │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  APPLICATIONS                                                 │
│    Ctrl+Alt+C      Zed                                        │
│    Ctrl+Alt+F      Dolphin (File Manager)                     │
│    Ctrl+Alt+B      Chrome browser                             │
│    Ctrl+Alt+M      System Monitor                             │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  WINDOW TILING                                                │
│    Meta+Up         Tile window top                            │
│    Meta+Down       Tile window bottom                         │
│    Meta+Left       Tile window left                           │
│    Meta+Right      Tile window right                          │
│    Meta+PgUp       Maximize window                            │
│    Meta+PgDown     Minimize window                            │
│    Alt+F4          Close window                               │
│    Meta+Ctrl+Esc   Kill window (force)                        │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  WINDOW NAVIGATION                                            │
│    Alt+Tab         Walk through windows                       │
│    Alt+`           Walk through windows of current app        │
│    Meta+Tab        Walk through windows (alternative)         │
│    Meta+W          Toggle Overview                            │
│    Meta+D          Peek at Desktop                            │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  VIRTUAL DESKTOPS                                             │
│    Ctrl+F1-F4      Switch to desktop 1-4                      │
│    Meta+Ctrl+←/→   Switch desktop left/right                  │
│    Meta+Ctrl+↑/↓   Switch desktop up/down                     │
│    Meta+Ctrl+Shift+←/→  Move window to desktop left/right     │
│    Meta+G          Grid view (overview)                       │
│    Meta+T          Toggle tiles editor                        │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  MULTI-MONITOR                                                │
│    Meta+Shift+←/→  Move window to prev/next screen            │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  SYSTEM                                                       │
│    Meta+L          Lock screen                                │
│    Ctrl+Alt+Del    Logout screen                              │
│    Meta+Alt+K      Switch keyboard layout                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  MEDIA KEYS                                                   │
│    Volume Up/Down  Adjust volume                              │
│    Volume Mute     Mute audio                                 │
│    Mic Mute        Mute microphone                            │
│    Media Play      Play/pause                                 │
│    Media Next/Prev Next/previous track                        │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  ZOOM & ACCESSIBILITY                                         │
│    Meta++/=        Zoom in                                    │
│    Meta+-          Zoom out                                   │
│    Meta+0          Reset zoom                                 │
│    Meta+Alt+S      Toggle screen reader                       │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  GHOSTTY (when focused)                                       │
│    Ctrl+Shift+\    New split right                            │
│    Ctrl+Shift+-    New split down                             │
│    Ctrl+Shift+HJKL Navigate splits                            │
│    Ctrl+Shift+W    Close split                                │
│    Ctrl+Shift+T    New tab                                    │
│    Ctrl+Tab        Next tab                                   │
│    Ctrl+Shift+U/D  Scroll page up/down                        │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        gaming|game)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                   LINUX GAMING (NVIDIA)                       │
├───────────────────────────────────────────────────────────────┤
│  STEAM LAUNCH OPTIONS                                         │
│    gamemoderun %command%                                      │
│    mangohud %command%                                         │
│    gamemoderun mangohud %command%     (both)                  │
│    PROTON_ENABLE_NVAPI=1 %command%    (DLSS support)          │
│    VKD3D_CONFIG=dxr %command%         (Ray tracing)           │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  MANGOHUD (in-game overlay)                                   │
│    Shift+F12     Toggle HUD                                   │
│    Shift+F1      Toggle FPS limit                             │
│    Config: ~/.config/MangoHud/MangoHud.conf                   │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  GAMEMODE                                                     │
│    gamemoded -s           Check if running                    │
│    gamemoderun <game>     Run with optimizations              │
│    Config: ~/.config/gamemode.ini                             │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  PROTON / WINE                                                │
│    protonup-qt            Manage Proton-GE versions           │
│    lutris                 Game launcher (GOG, Epic, etc.)     │
│    winetricks             Install Windows dependencies        │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  NVIDIA TOOLS                                                 │
│    nvidia-smi             GPU status/usage                    │
│    nvidia-settings        GUI settings                        │
│    nvtop                   GPU monitor (htop-like)            │
│    vulkaninfo             Vulkan info                         │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  TROUBLESHOOTING                                              │
│    PROTON_LOG=1 %command%         Enable Proton logs          │
│    DXVK_LOG_LEVEL=info %command%  Enable DXVK logs            │
│    __GL_SHADER_DISK_CACHE_PATH=/tmp/shader                    │
│    STEAM_COMPAT_DATA_PATH=<path>  Custom prefix               │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
        all|*)
            cat << 'EOF'
╭───────────────────────────────────────────────────────────────╮
│                    DEV SETUP CHEATSHEET                       │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  Usage: cheat [section]                                       │
│                                                               │
│  Sections:                                                    │
│    files, f     File operations (eza, bat, fd, rg)            │
│    git, g       Git commands and aliases                      │
│    docker, d    Docker and compose commands                   │
│    node, js, n  Node.js/npm/pnpm/bun                          │
│    fzf, fuzzy   FZF functions and keybindings                 │
│    system, s    System monitoring and management              │
│    python, py   Python commands                               │
│    tools, t     All installed modern tools                    │
│    herdr, hr    herdr agent multiplexer                       │
│    kde, k       KDE shortcuts (Rofi, Ghostty, apps)           │
│    gaming       Linux gaming (Steam, MangoHud, Proton)        │
│    all          This help                                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  QUICK REFERENCE                                              │
├───────────────────────────────────────────────────────────────┤
│  Files:    e/el/ea/et (eza)  b/bp (bat)  fd  rg  sg           │
│  Navigate: z/zi (zoxide)  y (yazi)  fcd  fo                   │
│  Git:      gs ga gc gp gpl lg  fgl fgb                        │
│  Docker:   d dc dcu dcd dps  db-start db-shell                │
│  System:   bt pss dust duf  sc scu                            │
│  Search:   rg sg frg batgrep  Ctrl+T Ctrl+R Alt+C             │
│  herdr:    Ctrl+Space prefix  Alt+Enter(split) Alt+1-9(tab)   │
│  KDE:      F12(dropdown) Alt+Space(rofi) Alt+V(clip)          │
├───────────────────────────────────────────────────────────────┤
│  Note: System commands (ls, cat, du, df, ping) are NOT        │
│  overridden - scripts will work normally.                     │
╰───────────────────────────────────────────────────────────────╯
EOF
            ;;
    esac
}

# Alias for quick access
alias help-aliases='cheat'
alias halp='cheat'
