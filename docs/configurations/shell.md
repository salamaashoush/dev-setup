# Shell Configuration Guide

## Overview

The shell environment uses Zsh with Zinit for plugin management. Tool init scripts are cached and plugins load after the first prompt, so startup stays fast: zsh-bench in an Arch container measured 37 ms to first prompt (was 49 ms), 26 ms to exit (was 36 ms), and 17.5 ms of lag per command. These are container measurements, not Mac numbers.

## Configuration Files

### ~/.zshrc
Main configuration file (`configs/zshrc`), in order:

1. **Cached Tool Init**: `_cached_source`, which sources tool init scripts from `~/.cache/zsh`
2. **Zinit Installation**: Auto-installs if missing
3. **Environment Variables**: Editors, pager, development paths
4. **PATH Configuration**: Homebrew shellenv, then mise and user paths, deduplicated
5. **Plugin Loading**: Turbo mode, after the first prompt
6. **History, Options, Key Bindings, Completion**
7. **Aliases & Functions**: `~/.config/shell/aliases.sh`, then shell functions
8. **Tool Initialization**: mise, starship, zoxide, direnv, fzf, vivid
9. **Local Overrides**: `~/.zshrc.local`, kept out of version control

### ~/.config/shell/aliases.sh
Every alias and most functions (`configs/aliases.sh`), including all git and docker shortcuts. It does not override `ls`, `cat`, `grep`, `find`, `du` or `df`, so scripts see the standard commands.

## Key Features

### Cached Tool Init

brew, mise, starship, zoxide, direnv, fzf and vivid each print a static init script. Spawning all of them on every start costs more than the rest of startup combined, so `.zshrc` sources a cached copy from `~/.cache/zsh`. The cache is keyed on each binary's path, inode, size and mtime, so upgrading a tool rebuilds its script automatically.

```bash
# Force a rebuild of every cached init script
rm -rf ~/.cache/zsh
```

### Smart PATH Management

```bash
# Automatic deduplication
typeset -U path PATH

# macOS: brew shellenv (cached), from /opt/homebrew on Apple Silicon or
# /usr/local on Intel. Loaded first so mise and user paths win over brew.
path=(
    "$HOME/.local/share/mise/shims"
    "$HOME/.local/bin"
    "$CARGO_HOME/bin"
    "$BUN_INSTALL/bin"
    "$PNPM_HOME"
    $path
)
```

### FZF Integration

Tokyo Night Storm colors from folke/tokyonight.nvim:

```bash
export FZF_DEFAULT_OPTS="
  --height 50%
  --layout=reverse
  --border=rounded
  --color=bg+:#2e3c64,bg:#1f2335,gutter:#1f2335,border:#29a4bd
  --color=fg:#c0caf5,hl:#2ac3de,hl+:#2ac3de,query:#c0caf5:regular
  --color=header:#ff9e64,info:#545c7e,separator:#ff9e64,scrollbar:#29a4bd
  --color=marker:#ff007c,pointer:#ff007c,prompt:#2ac3de,spinner:#ff007c
"

# Use fd for faster file finding
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .venv'
```

`Ctrl+T` previews files with bat, `Alt+C` previews directories with eza, and `Ctrl+Y` inside `Ctrl+R` copies the selected command.

### Directory Navigation

```bash
# Zoxide: z to jump, zi for interactive; cd is untouched
z project
zi project

# fcd: pick from zoxide's directory list (fd when zoxide is missing)
fcd

# Quick navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
```

## Essential Aliases

`aliases.sh` is the single source for aliases. Run `cheat` for the full list.

### File Operations
```bash
alias ll='eza -l --icons --git --header --group-directories-first'
alias la='eza -la --icons --git --header --group-directories-first'
alias lt='eza --tree --icons --git --level=2 --group-directories-first'
alias b='bat --style=auto --paging=never'
alias bcat='bat --style=plain --paging=never'
```

### Git Shortcuts
```bash
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gst='git stash'
alias lg='lazygit'
```

Oh My Zsh's git plugin is not loaded, and several of these differ from it: `gst` is `git stash` (OMZ: `git status`) and `gl` is the log graph (OMZ: `git pull`).

### Docker
```bash
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dps='docker ps'
alias dex='docker exec -it'
```

### Development
```bash
alias yolo='claude --dangerously-skip-permissions'
alias hr='herdr'
alias pyvenv='uv venv'
y             # yazi; cd to its directory on quit
hrs <name>    # herdr session, attach or create
```

### System
```bash
reload        # exec zsh (re-sourcing ~/.zshrc stacks hooks)
myip          # public IP
killport 3000 # kill whatever listens on a port
fkill         # pick processes with fzf and send SIGTERM (fkill 9 for SIGKILL)
copy          # pbcopy, wl-copy, or xclip
```

There is no `paste` alias: it shadowed the system `paste` utility. Use `pbpaste` (macOS) or `wl-paste` (Wayland).

## Zinit Plugins

Loaded in turbo mode, after the first prompt:

```bash
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    OMZP::sudo

zinit snippet OMZP::command-not-found
```

- **fast-syntax-highlighting**: Command highlighting
- **zsh-autosuggestions**: History suggestions, fetched asynchronously and skipped for buffers over 40 characters
- **zsh-completions**: Additional completions
- **OMZ sudo**: Press `Esc` twice to put `sudo` in front of the line
- **OMZ command-not-found**: Suggests the package that provides a missing command

Oh My Zsh's git, docker and kubectl plugins and the zinit annexes are not loaded.

## History & Key Bindings

```bash
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
```

- `Up` / `Down` → Search history for lines starting with what is already typed
- `Alt+Left/Right` (`Option` on macOS), `Ctrl+Left/Right` → Jump words
- `Ctrl+R` → Fuzzy history search (fzf)
- `Ctrl+G` → lazygit
- `Esc Esc` → Prefix the line with `sudo`

## Language-Specific Setup

### mise
```bash
# Activated first in the tool init block, so the tools initialised after it
# resolve to real binaries rather than shims
_cached_source mise-activate mise mise activate zsh
```

Node.js, Bun, Rust and the rest come from `~/.config/mise/conf.d/dev-setup.toml`.

### Rust
```bash
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
```

## Starship Prompt

Configured in `~/.config/starship.toml` (from `configs/starship.toml`). Two lines: the directory, git branch, git status with counts, language versions, command duration over 2 seconds, background jobs, and battery under 20%, then a `❯` on the second line (red after a failed command). Over SSH the host leads the first line. There is no right prompt; `.zshrc` unsets `RPROMPT` so Starship is not run twice per prompt.

```toml
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$nodejs\
$bun\
$rust\
$python\
$golang\
$docker_context\
$aws\
$kubernetes\
$cmd_duration\
$jobs\
$battery\
$line_break\
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[cmd_duration]
min_time = 2000
```

## Environment Variables

### Development
```bash
export EDITOR="nvim"
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
export PAGER="less"
export LESS="-R --mouse"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # set in aliases.sh when bat is installed
```

### SSH
```bash
# Linux: set in ~/.config/environment.d/wayland.conf for the ssh-agent user service
SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
```

On macOS the agent is the system one, with the key passphrase in the Keychain (`UseKeychain` in `~/.ssh/config`).

## Troubleshooting

### Slow Startup
1. Measure with: `time zsh -i -c exit`
2. Profile with: `zsh -xvs`
3. Rebuild cached init scripts: `rm -rf ~/.cache/zsh`
4. Disable plugins one by one

### Command Not Found
1. Check PATH: `echo $PATH | tr ':' '\n'`
2. Verify installation: `which <command>`, or `mise ls` for tools from mise
3. Reload shell: `exec zsh`
4. Check platform-specific paths

### Plugin Issues
1. Update Zinit: `zinit self-update`
2. Update plugins: `zinit update --all`
3. Clear cache: `rm -rf ~/.local/share/zinit/completions/*`
4. Recompile: `zinit compile --all`

## Best Practices

1. **Keep it fast**: Target <100ms startup
2. **Lazy load**: Defer non-essential plugins
3. **Platform aware**: Use conditionals for OS-specific code
4. **Modular**: Separate concerns into functions
5. **Document**: Comment non-obvious configurations
