# shellcheck shell=bash
# Shortcuts for a person at the keyboard. zshrc skips this file in agent
# shells, so agents see stock commands. Nothing here shadows a real command.
# Each entry's trailing comment is what `cheat` prints.

# Listing and moving
alias ll='eza -l --git --icons --group-directories-first'          # long listing
alias la='eza -la --git --icons --group-directories-first'         # long listing with hidden files
alias lt='eza --tree --level=2 --icons --group-directories-first'  # tree, two levels
alias ..='cd ..'                                                   # up one directory
alias ...='cd ../..'                                               # up two directories
mkcd() { mkdir -p "$1" && cd "$1" || return; }                     # make a directory and enter it

# Git
alias g='git'                                         # git
alias gs='git status -sb'                             # short status
alias gd='git diff'                                   # unstaged diff
alias gds='git diff --staged'                         # staged diff
alias gl='git log --oneline --graph --decorate -20'   # last 20 commits as a graph
alias gp='git push'                                   # push
alias gpf='git push --force-with-lease'               # force-push, refusing to drop others' commits
alias gsw='git switch'                                # switch branch
alias lg='lazygit'                                    # lazygit

# Agents: one worktree per parallel session, so their edits never collide
alias yolo='claude --dangerously-skip-permissions'    # Claude Code without permission prompts
alias ccc='claude --continue'                         # continue the latest Claude Code session here
alias ccr='claude --resume'                           # pick a Claude Code session to resume
hrs() { herdr --session "${1:-dev}"; }                # attach to a herdr session, creating it if needed
alias wtl='git worktree list'                         # list worktrees

wt() {  # wt <branch> [base]: worktree beside the repo for <branch>, then enter it
    local branch="${1:?usage: wt <branch> [base]}" base="${2:-HEAD}" root dir
    root=$(git rev-parse --show-toplevel) || return
    dir="$(dirname "$root")/$(basename "$root")-${branch//\//-}"
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$dir" "$branch"
    else
        git worktree add -b "$branch" "$dir" "$base"
    fi && cd "$dir" || return
}

wtrm() {  # wtrm [dir]: remove a worktree (git refuses if it has uncommitted work)
    local dir main
    dir=$(git -C "${1:-$PWD}" rev-parse --show-toplevel) || return
    main=$(git -C "$dir" worktree list --porcelain | awk 'NR==1 {print $2}')
    [[ "$dir" == "$main" ]] && { echo "$dir is the main worktree"; return 1; }
    git -C "$main" worktree remove "$dir" || return
    [[ "$PWD" == "$dir"* ]] && cd "$main"
}

# Docker
alias d='docker'                       # docker
alias dcu='docker compose up -d'       # start the compose project
alias dcd='docker compose down'        # stop the compose project
alias dcl='docker compose logs -f'     # follow compose logs

# Find and open (fzf)
fo() {  # fuzzy-find a file and open it in $EDITOR
    local file
    file=$(fzf --preview 'bat --color=always --line-range :300 {}') && "${EDITOR:-nvim}" "$file"
}

fcd() {  # fuzzy-jump to a directory zoxide knows
    local dir
    dir=$(zoxide query -l | fzf --preview 'eza --tree --level=2 --color=always {}') && cd "$dir" || return
}

frg() {  # frg <pattern>: ripgrep, pick a match, open it at that line
    local hit
    hit=$(rg --line-number --no-heading --color=always "$@" \
        | fzf --ansi --delimiter=: --preview 'bat --color=always --highlight-line {2} {1}' --preview-window '+{2}/2') || return
    "${EDITOR:-nvim}" "$(cut -d: -f1 <<<"$hit")" "+$(cut -d: -f2 <<<"$hit")"
}

fgb() {  # fuzzy-switch to a local branch
    local branch
    branch=$(git branch --format='%(refname:short)' | fzf --preview 'git log --oneline --graph --color=always -30 {}') && git switch "$branch"
}

y() {  # yazi, landing in the directory it was left in
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
    yazi "$@" --cwd-file="$tmp"
    cwd="$(<"$tmp")"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd "$cwd"
    rm -f "$tmp"
}

# Utilities
killport() {  # killport <port>: stop whatever listens on a port
    local pids
    pids=$(lsof -ti :"${1:?usage: killport <port>}") || { echo "Nothing on port $1"; return 1; }
    echo "$pids" | xargs kill
}

extract() {  # extract <archive>: unpack any common archive format
    case "${1:?usage: extract <archive>}" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.tar.zst|*.tar) tar xf "$1" ;;
        *.zip) unzip "$1" ;;
        *.gz) gunzip "$1" ;;
        *.7z) 7z x "$1" ;;
        *.zst) unzstd "$1" ;;
        *) echo "Cannot extract $1"; return 1 ;;
    esac
}

serve() { python3 -m http.server "${1:-8000}"; }  # serve this directory over HTTP

dev-cleanup() {  # prune build and package caches across every project
    command -v mbx >/dev/null && mbx gc
    if [[ "$OSTYPE" == darwin* ]]; then brew cleanup; fi
    pnpm store prune 2>/dev/null
    uv cache clean 2>/dev/null
    docker system prune -f 2>/dev/null
}

if [[ "$OSTYPE" == darwin* ]]; then
    alias o='open'       # open with the default app
    alias copy='pbcopy'  # copy stdin to the clipboard
else
    alias o='xdg-open'   # open with the default app
    alias copy='wl-copy' # copy stdin to the clipboard
fi

# man pages through bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

[[ -f "$HOME/.config/shell/project-templates.sh" ]] && source "$HOME/.config/shell/project-templates.sh"

cheat() {  # list every shortcut in this file
    local file="$HOME/.config/shell/aliases.sh"
    sed -nE 's/^ *alias ([^=]+)=.*# (.*)$/\1\t\2/p; s/^([a-z][a-z0-9_-]*)\(\) \{.*# (.*)$/\1\t\2/p' "$file" \
        | sort -u | column -t -s $'\t'
}
