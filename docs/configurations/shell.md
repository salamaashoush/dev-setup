# Shell Configuration Guide

## Overview

The shell environment uses Zsh with Zinit for plugin management, optimized for sub-100ms startup times while providing powerful features.

## Configuration Files

### ~/.zshrc
Main configuration file with modular sections:

1. **Zinit Installation**: Auto-installs if missing
2. **Performance Optimizations**: Lazy loading, compilation
3. **Environment Variables**: Cross-platform paths
4. **PATH Configuration**: Deduplication, platform-specific
5. **Plugin Loading**: Conditional, performance-focused
6. **Aliases & Functions**: Productivity shortcuts
7. **Tool Initialization**: Language-specific setups

## Key Features

### Performance Optimizations

```bash
# Compile zcompdump for faster loading
zcompile ~/.zcompdump

# Lazy load nvm equivalent
zinit light-mode for \
    OMZL::nvm.zsh \
    as"completion" OMZP::nvm

# Turbo mode for deferred loading
zinit wait lucid for \
    OMZP::git \
    OMZP::docker
```

### Smart PATH Management

```bash
# Automatic deduplication
typeset -U path PATH

# Platform-aware additions
if [[ "$OSTYPE" == "darwin"* ]]; then
    path=("/opt/homebrew/bin" $path)
else
    path=("/usr/local/bin" $path)
fi
```

### FZF Integration

Enhanced fuzzy finding with Tokyo Night theme:

```bash
export FZF_DEFAULT_OPTS='
  --height=50%
  --layout=reverse
  --border=rounded
  --preview-window=right:50%:wrap
  --color=bg+:#414559,bg:#303446,spinner:#f2d5cf
'

# Use fd for faster file finding
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
```

### Directory Navigation

```bash
# Zoxide configuration
eval "$(zoxide init zsh)"

# Better cd with automatic ls
cd() {
    builtin cd "$@" && eza -la
}

# Quick navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
```

## Essential Aliases

### File Operations
```bash
alias ls='eza'
alias l='eza -la'
alias ll='eza -l'
alias lt='eza --tree'
alias cat='bat'
alias grep='rg'
alias find='fd'
```

### Git Shortcuts
```bash
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'
```

### Development
```bash
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias c='code'
alias z='zed'
alias cur='cursor'
```

### System
```bash
alias reload='source ~/.zshrc'
alias update='topgrade'
alias ports='netstat -tulanp'
alias myip='curl -s https://api.ipify.org'
```

## Zinit Plugins

### Syntax & Completion
```bash
# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Auto-suggestions based on history
zinit light zsh-users/zsh-autosuggestions

# Additional completions
zinit light zsh-users/zsh-completions
```

### History Enhancement
```bash
# Better history search
zinit light zsh-users/zsh-history-substring-search

# History configuration
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
```

### Productivity Plugins
```bash
# Extract any archive
zinit light OMZP::extract

# Colored man pages
zinit light OMZP::colored-man-pages

# Git plugin (aliases and functions)
zinit wait lucid for OMZP::git
```

## Language-Specific Setup

### Node.js (fnm)
```bash
# Fast Node Manager
if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi
```

### Python
```bash
# UV (Astral) 
export UV_SYSTEM_PYTHON=1

# Poetry
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Pyenv (if used)
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi
```

### Rust
```bash
# Cargo binaries
export PATH="$HOME/.cargo/bin:$PATH"

# Sccache for faster builds
export RUSTC_WRAPPER="sccache"
```

### Go
```bash
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
```

## Starship Prompt

Configured in `~/.config/starship.toml`:

```toml
# Tokyo Night Storm theme
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$rust\
$golang\
$nodejs\
$character"""

[directory]
style = "blue bold"
truncation_length = 3
truncate_to_repo = true

[git_branch]
style = "purple bold"
symbol = " "

[git_status]
style = "red bold"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
```

## Environment Variables

### Development
```bash
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

### Security
```bash
# GPG
export GPG_TTY=$(tty)

# SSH
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
```

### Tool-Specific
```bash
# Homebrew (macOS)
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```

## Troubleshooting

### Slow Startup
1. Check with: `zsh -xvs`
2. Profile with: `time zsh -i -c exit`
3. Disable plugins one by one
4. Ensure zcompdump is compiled

### Command Not Found
1. Check PATH: `echo $PATH | tr ':' '\n'`
2. Verify installation: `which <command>`
3. Reload shell: `exec zsh`
4. Check platform-specific paths

### Plugin Issues
1. Update Zinit: `zinit self-update`
2. Update plugins: `zinit update --all`
3. Clear cache: `rm -rf ~/.zinit/completions/*`
4. Recompile: `zinit compile --all`

## Best Practices

1. **Keep it fast**: Target <100ms startup
2. **Lazy load**: Defer non-essential plugins
3. **Platform aware**: Use conditionals for OS-specific code
4. **Modular**: Separate concerns into functions
5. **Document**: Comment non-obvious configurations