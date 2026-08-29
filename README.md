# 🚀 Dev Setup - Cross-Platform Development Environment

> A comprehensive, AI-powered development environment setup for macOS and Linux with modern tools, smart defaults, and extensive automation.

![Platform Support](https://img.shields.io/badge/Platform-macOS%20|%20Arch%20Linux-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-2.0.0-orange)

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Architecture](#architecture)
5. [Modules & Features](#modules--features)
6. [Configurations](#configurations)
7. [Keyboard Shortcuts](#keyboard-shortcuts)
8. [Command Aliases](#command-aliases)
9. [Tool Choices & Rationale](#tool-choices--rationale)
10. [Claude Code Integration](#claude-code-integration)
11. [Testing](#testing)
12. [Uninstallation](#uninstallation)
13. [Upgrading](#upgrading)
14. [Contributing](#contributing)
15. [Troubleshooting](#troubleshooting)
16. [License](#license)

## Overview

This setup provides a complete development environment with:

- **200+ modern development tools**
- **AI-powered coding assistance** via Claude Code
- **Cross-platform support** (macOS and Linux/Arch)
- **Smart defaults** and performance optimizations
- **Extensive automation** and quality-of-life improvements

## Prerequisites

### System Requirements

**macOS:**
- macOS 12.0 (Monterey) or later
- Intel or Apple Silicon processor
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- Administrator access

**Linux (Arch):**
- Arch Linux (latest)
- x86_64 or ARM64 architecture
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- sudo privileges

### Required Software

- **Git**: For cloning the repository
- **Bash**: Version 4.0 or later
- **Internet connection**: For downloading packages

### Key Features

- ✅ **Smart UX**: Accepts variations like `y`, `yes`, `yep`, `ok` for confirmations
- ✅ **Batch Mode**: Fully automated installation with config file
- ✅ **Modern CLI Tools**: Faster, prettier alternatives to traditional tools
- ✅ **AI Integration**: Claude Code with custom commands and hooks
- ✅ **Cross-Platform**: Works seamlessly on macOS and Linux

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dev-setup.git ~/dev-setup
cd ~/dev-setup

# Run the installer
./setup-all.sh
```

### System-Specific Notes

**macOS:**
- Xcode Command Line Tools will be installed automatically if missing
- Homebrew will be installed automatically if missing

**Arch Linux:**
- System will be updated automatically (`pacman -Syu`)
- yay AUR helper will be installed automatically if missing

### What Gets Installed

The setup script installs:

- **Shell & Terminal**: Zsh, Kitty, Starship prompt, essential CLI tools
- **Development Tools**: Node.js, Python, Rust (via rustup), Go, and their package managers
- **Version Managers**: fnm (Node), SDKMAN (Java), ghcup (Haskell)
- **Editors**: Neovim, Helix, VS Code, Zed, Cursor
- **Container Tools**: Docker, Colima (macOS), lazydocker
- **Cloud Tools**: kubectl, helm, terraform, AWS/Azure/GCP CLIs
- **AI Tools**: Claude Code, Ollama, LM Studio
- **Gaming**: Steam, Lutris, Wine, GameMode, MangoHud, plus multiplayer hosting tools (`gamenet`, `game-firewall`)
- **And much more**: 200+ tools total

### Post-Installation

After installation:

1. **Restart your terminal** for all changes to take effect
2. **Check the documentation** in the `docs/` folder
3. **Linux users**: Consider rebooting for system optimizations to take effect
4. **Review keyboard shortcuts**: `~/.config/keyboard-shortcuts-reference.md`

## Architecture

### Directory Structure

```
mac-dev-setup/
├── setup-all.sh          # Main installer script (all-in-one)
├── configs/
│   ├── aliases.sh        # Shell aliases
│   ├── gitconfig         # Git configuration template
│   ├── gitignore_global  # Global gitignore
│   ├── gitmessage        # Git commit template
│   ├── kitty.conf        # Kitty terminal config
│   ├── kitty-session.conf # Kitty session config
│   ├── starship.toml     # Starship prompt config
│   ├── zshrc             # Zsh configuration
│   ├── lazygit.yml       # Lazygit config
│   ├── btop.conf         # System monitor config
│   ├── ripgreprc         # Search tool config
│   ├── zellij.kdl        # Zellij multiplexer config
│   ├── topgrade.toml     # Topgrade updater config
│   ├── tokyonight-storm.yml # Theme configuration
│   ├── project-templates.sh # Project template generator
│   ├── project-templates/   # Project templates
│   ├── scripts/             # Scripts installed to ~/.local/bin (x3d-mode to /usr/local/bin)
│   │   ├── game-firewall.sh # Open ufw for multiplayer hosting
│   │   ├── gamenet.sh       # Diagnose multiplayer connectivity
│   │   ├── x3d-mode.sh      # AMD X3D CCD preference switch
│   │   └── ghostty-dropdown.sh # Drop-down terminal toggle
│   ├── claude/           # Claude Code configs
│   │   ├── CLAUDE.md     # Claude instructions
│   │   └── commands/     # Custom commands
│   ├── vscode/           # VS Code settings
│   ├── zed/              # Zed editor settings
│   ├── helix/            # Helix editor configs
│   ├── yazi/             # Yazi file manager
│   ├── rofi/             # Rofi launcher configs
│   ├── colima/           # Colima configs
│   └── docker/           # Docker configs
├── docs/                 # Documentation
│   ├── README.md         # Docs overview
│   ├── QUICK_REFERENCE.md # Quick reference guide
│   ├── configurations/   # Config documentation
│   ├── rationale/        # Design decisions
│   ├── shortcuts/        # Keyboard shortcuts
│   ├── tools/            # Tool documentation
│   └── troubleshooting/  # Common issues
├── scripts/              # Utility scripts
│   └── git-clone-bare-for-worktrees.sh  # Git worktree helper
├── LICENSE               # MIT License
└── CONTRIBUTING.md       # Contribution guide

```

### Setup Process

The `setup-all.sh` script performs the following steps:

1. **Pre-flight Checks**: Platform detection, dependency installation
2. **System Optimizations**: OS-specific performance tweaks
3. **Terminal & Shell**: Zsh, Kitty, CLI tools, themes
4. **Git Configuration**: Git setup, SSH keys, helper scripts
5. **Development Tools**: Languages, editors, containers, cloud tools
6. **Productivity Apps**: Window managers, launchers, utilities
7. **Advanced Tools**: AI/ML, performance, specialized tools
8. **Keyboard Shortcuts**: System-wide shortcuts and documentation

## Features

### System Optimization

**macOS Optimizations:**

- Homebrew installation and optimization
- System preferences for developers
- Security settings (firewall, privacy)
- Performance tuning (SSD optimization)

**Linux/Arch Optimizations:**

- KDE Plasma 6 configuration
- NVIDIA + Wayland support
- Package manager optimization
- System service configuration

### Terminal Setup

**Shell Environment:**

- Zsh with Zinit (fast plugin manager)
- Starship prompt (cross-platform)
- Smart directory navigation (zoxide)

**Modern CLI Tools Installed:**

| Traditional | Modern Replacement | Benefits                           |
| ----------- | ------------------ | ---------------------------------- |
| `ls`        | `eza`              | Icons, git integration, tree view  |
| `cat`       | `bat`              | Syntax highlighting, line numbers  |
| `grep`      | `ripgrep`          | 10x faster, smart defaults         |
| `find`      | `fd`               | Intuitive syntax, faster           |
| `top`       | `btop`             | Beautiful UI, mouse support        |
| `du`        | `dust`             | Visual tree, easier to read        |
| `df`        | `duf`              | Colorful, grouped output           |
| `cd`        | `zoxide`           | Learns your habits, fuzzy matching |
| `man`       | `tldr`             | Practical examples, concise        |
| `diff`      | `delta`            | Syntax highlighting, side-by-side  |

### Git Configuration

**Features:**

- Enhanced gitconfig with 60+ aliases
- Delta integration for beautiful diffs
- Performance optimizations
- Smart defaults (auto-stash, rerere)
- Lazygit for TUI interface

### Development Tools

**Programming Languages:**

- **Node.js** via fnm (Fast Node Manager)
- **Python** via pyenv with virtualenv
- **Rust** via rustup (official installer)
- **Go** latest stable
- **Java/Kotlin** via SDKMAN
- **Haskell** via ghcup
- **Bun** JavaScript runtime

**Development Environment:**

- Neovim with LazyVim
- VS Code with 80+ extensions
- Docker alternatives (Colima/OrbStack)
- Database tools (PostgreSQL, MySQL, Redis)
- API tools (HTTPie, Postman, Insomnia)

### Productivity Apps

**Communication:**

- Slack, Discord, Zoom, Teams

**Productivity:**

- Raycast/Alfred (launchers)
- Rectangle (window management)
- CleanMyMac (system maintenance)

### Gaming Network

Multiplayer hosting fails silently on a default Arch/CachyOS install: `ufw` drops all
inbound connections, and it also drops the router's UPnP reply — so games cannot even
forward their own ports. Two tools are installed to `~/.local/bin`:

| Command | Purpose |
|---------|---------|
| `gamenet check [port]` | Diagnose host firewall, router UPnP, CGNAT, and end-to-end reachability |
| `sudo game-firewall` | Open `ufw` for Steam and ~30 self-hosted game servers (idempotent) |
| `gamenet map <port> [proto]` | Add a UPnP port mapping manually |

The LAN subnet is auto-detected from the default route, so both work on any network.
`DEFAULT_INPUT_POLICY` stays `DROP` — specific ports are opened, the firewall is not disabled.

See [docs/tools/gaming-network.md](docs/tools/gaming-network.md) for the full
explanation, including why enabling UPnP on the router appears to do nothing until
the host firewall is fixed first.

### Game Development

Prompted (large download). Godot and Blender, the Vulkan stack with validation layers
(including `lib32-` variants for Proton/32-bit titles), RenderDoc and Tracy for
profiling, `lldb`/`gdb`, and the system libraries Rust engines like Bevy link against
on Linux.

See [docs/tools/game-development.md](docs/tools/game-development.md).

### CachyOS & Hardware Tuning

CachyOS ships its own tuned defaults, so generic Arch tuning is deliberately skipped.
What the installer adds are the hardware knobs left at defaults:

| Feature | What it does |
|---------|--------------|
| `x3d-mode` | Switch CCD preference on 7950X3D/9950X3D — V-Cache for gaming, high-clock for compiling |
| GameMode hook | Opt-in: switch to the V-Cache CCD automatically while a game runs |
| `scx_loader` | Opt-in: enable pluggable `sched_ext` schedulers (`scx_lavd` for gaming) |
| NVIDIA open modules | Detects Blackwell (RTX 50), where proprietary modules are unsupported |
| Hybrid GPU | Installs drivers for discrete **and** integrated GPUs, not just the first match |

See [docs/tools/cachyos-hardware.md](docs/tools/cachyos-hardware.md).

### Advanced Dev Tools

**Categories:**

- AI/ML tools (Jupyter, TensorFlow, PyTorch)
- DevOps & Cloud (AWS CLI, Google Cloud CLI)
- Infrastructure as Code (Ansible, Pulumi)
- Security analysis tools (Semgrep, Burp Suite)
- Performance profiling (perf, Valgrind, FlameGraph)
- Creative tools (ImageMagick, FFmpeg)
- Communication & Security (Discord, Slack, 1Password)

**Note on HashiCorp Tools:**
- Terraform, Vagrant, and Packer have been removed due to their Business Source License (BUSL) change
- For Terraform functionality, consider using Pulumi or OpenTofu as open-source alternatives
- The Terraform version manager (tfenv) remains available if you need to manage legacy Terraform installations

### Module 07: Keyboard Shortcuts

**System Integration:**

- **macOS**: System shortcuts, Raycast configuration, window management
- **Linux/KDE**: Plasma shortcuts, Rofi integration, virtual desktops
- **Cross-platform**: Consistent terminal and editor shortcuts

**Features:**

- Application launch shortcuts (Terminal, VS Code, Browser)
- Window management (tiling, maximize, workspaces)
- Clipboard history and emoji pickers
- Developer-focused workflows
- Comprehensive documentation generated at `~/.config/keyboard-shortcuts-reference.md`

## Configurations

### Shell Configuration (zshrc)

**Performance Features:**

- Lazy loading with Zinit turbo mode
- Compiled zcompdump for faster startup
- Smart PATH management (no duplicates)
- Platform-specific optimizations

**Key Settings:**

```bash
# Environment variables
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export SDKMAN_DIR="$HOME/.sdkman"

# History settings
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Tool initialization (lazy loaded)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd)"
```

### Terminal Configuration
- Cross-platform keybindings
- Built-in multiplexing

#### Kitty (kitty.conf)

**Features:**
- GPU acceleration for rendering
- Extensive keyboard shortcuts
- Split pane management
- Shell integration
- Remote control capabilities

**Color Scheme:**

- Tokyo Night Storm theme (consistent across all tools)
- Font stack: CaskaydiaCove NF → JetBrains Mono → Cascadia Code → Fira Code
- Nerd Font icons support
- Theme applied to: Kitty, Starship, Lazygit, Delta, and more

### Git Configuration

**Performance Settings:**

```ini
[core]
    commitGraph = true
    pager = delta

[feature]
    manyFiles = true

[fetch]
    writeCommitGraph = true
    parallel = 0

[pack]
    useBitmaps = true
    writeBitmapLookupTable = true
```

**Useful Aliases:**

```ini
[alias]
    # Quick commits
    cm = !git add -A && git commit -m
    wip = !git add -u && git commit -m "WIP"
    unwip = !git log -n 1 --oneline | grep -q -c "WIP" && git reset HEAD~1

    # Branch management
    cleanup = !git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d
    recent = branch --sort=-committerdate --format=\"%(committerdate:relative)%09%(refname:short)\"

    # Advanced operations
    rebase-onto = !bash -c 'git rebase --onto $1 $2 ${3:-HEAD}' -
    sync = !git fetch --all && git rebase origin/$(git branch --show-current)
```

### Starship Prompt Configuration

**Minimal Design:**

- Shows only essential information
- Git branch and status
- Command duration (if >500ms)
- Language versions when in project
- Battery status on laptops


**Auto-corrections:**

- Common typos (teh→the)
- Date/time insertions (`:date`, `:time`)
- Emojis (`:check`→✅, `:fire`→🔥)
- Git commit types (`:feat`, `:fix`)

## Keyboard Shortcuts
| `CMD/CTRL + Arrow`         | Navigate panes       |
| `ALT + h/j/k/l`            | Vim-style navigation |
| `CMD/CTRL + SHIFT + Arrow` | Resize panes         |
| `CMD/CTRL + t`             | New tab              |
| `CMD/CTRL + [/]`           | Switch tabs          |
| `CMD/CTRL + z`             | Toggle zoom          |
| `CMD/CTRL + v`             | Copy mode            |

### Lazygit

| Key      | Action                 |
| -------- | ---------------------- |
| `C`      | Commit with commitizen |
| `T`      | Show git tree          |
| `Ctrl+R` | Create pull request    |
| `Ctrl+V` | View pull request      |
| `P`      | Push                   |
| `p`      | Pull                   |
| `f`      | Fetch                  |

### Btop (System Monitor)

| Key       | Action                 |
| --------- | ---------------------- |
| `h/j/k/l` | Vim navigation         |
| `/`       | Filter processes       |
| `k`       | Kill process (shift+k) |
| `s`       | Sort selection         |
| `t`       | Tree view              |
| `p`       | Toggle program path    |

## Command Aliases

### Shell Navigation & Tools

```bash
# Modern replacements
alias ls='eza --icons --git'
alias ll='eza -l --icons --git --header'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'
alias top='btop'
alias du='dust'
alias df='duf'
alias cd='z'  # zoxide

# Claude CLI
alias claude='$HOME/.claude/local/claude'
alias yolo='$HOME/.claude/local/claude --dangerously-skip-permissions'
alias c='$HOME/.claude/local/claude'
alias cy='$HOME/.claude/local/claude --dangerously-skip-permissions'
```

### Git Shortcuts

```bash
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias lg='lazygit'
```

### Docker/Container Management

```bash
alias d='docker'
alias dc='docker-compose'
alias dr='docker run --rm -it'
alias dex='docker exec -it'
alias docker-start='colima start'  # macOS
alias docker-stop='colima stop'     # macOS
```

### Utility Functions

```bash
# Create and enter directory
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extract archives
extract() { /* handles .tar.gz, .zip, etc. */ }

# Git clone and cd
gclone() { git clone "$1" && cd "$(basename "$1" .git)"; }

# Quick file server
serve() { python3 -m http.server "${1:-8000}"; }

# Weather check
weather() { curl -s "wttr.in/${1:-}"; }
```

## Tool Choices & Rationale

### Why These Tools?

**Modern CLI Replacements:**

- **Performance**: Tools like `ripgrep` and `fd` are 10x faster than traditional alternatives
- **User Experience**: Better defaults, colors, and intuitive interfaces
- **Cross-Platform**: All tools work on both macOS and Linux
- **Active Development**: Modern tools receive regular updates

**Development Environment:**

- **fnm over nvm**: Faster Node.js version management
- **pyenv**: Consistent Python version management
- **Colima over Docker Desktop**: Lighter weight, less resource usage
- **Kitty**: GPU acceleration, excellent performance

**AI Integration:**

- **Claude Code**: AI-powered coding assistance
- **Custom Commands**: Domain-specific AI workflows
- **Smart Hooks**: Automated quality checks

### Performance Optimizations

1. **Shell Startup**: <200ms with Zinit lazy loading
2. **Git Operations**: Parallel fetch, commit graph, bitmap indexes
3. **Terminal Rendering**: GPU acceleration, 120 FPS
4. **File Search**: `ripgrep` uses SIMD, parallelization
5. **Directory Navigation**: `zoxide` uses frecency algorithm

## Claude Code Integration

### Custom Commands

**`/agentic-review`** - Comprehensive code review

- Security vulnerability analysis
- Performance bottleneck detection
- Architecture pattern evaluation
- Technical debt assessment

**`/architect`** - Software architecture design

- System design recommendations
- Technology stack evaluation
- Scalability planning
- API design patterns

**`/debug-deep`** - Systematic debugging

- Root cause analysis
- Hypothesis-driven investigation
- Evidence collection
- Solution development

**`/optimize`** - Performance optimization

- Algorithm complexity analysis
- Memory usage optimization
- I/O performance improvements
- Caching strategies

### Smart Hooks

**Auto-formatting:**

```json
{
  "id": "auto-format",
  "event": "PostToolUse",
  "tool": "Write",
  "action": {
    "type": "bash",
    "command": "prettier --write $CLAUDE_TOOL_FILE_PATH"
  }
}
```

**Context Detection:**

- Detects keywords in prompts
- Suggests relevant commands
- Example: "performance" → suggests `/optimize`

### Usage Examples

```bash
# Code review
claude /agentic-review src/

# Architecture design
claude /architect "Build scalable microservices API"

# Quick dangerous mode
yolo "Fix all the bugs"

# Performance optimization
c /optimize database/queries.py
```

## Testing

### Running Tests

The project includes a comprehensive test suite using Docker:

```bash
# Run all tests
./docker/run-tests.sh

# Run tests for specific platform
./docker/run-tests.sh --platform macos
./docker/run-tests.sh --platform arch

# Run in verbose mode
./docker/run-tests.sh --verbose
```

### Test Coverage

- Module installation validation
- Configuration file integrity
- Cross-platform compatibility
- Tool availability checks
- Performance benchmarks

## Uninstallation

### Removing the Setup

While there's no automated uninstall script, you can remove components:

**1. Remove installed packages:**

```bash
# macOS - List and remove Homebrew packages
brew list --formula | xargs brew uninstall --force
brew list --cask | xargs brew uninstall --force

# Arch Linux - Remove packages
pacman -Qe | grep -v base | xargs sudo pacman -Rs
```

**2. Remove configurations:**

```bash
# Backup first if needed
cp -r ~/.config ~/config-backup

# Remove configurations
rm -rf ~/.config/zsh ~/.config/starship ~/.config/kitty
rm -rf ~/.config/btop ~/.config/lazygit
rm -rf ~/.zshrc ~/.gitconfig ~/.ripgreprc
```

**3. Remove development tools:**

```bash
# Node.js
rm -rf ~/.fnm

# Python
rm -rf ~/.pyenv

# Rust
rustup self uninstall

# Other tools
rm -rf ~/.sdkman ~/.ghcup ~/.bun
```

## Upgrading

### Updating an Existing Installation

**1. Update the repository:**

```bash
cd ~/dev-setup
git pull origin main
```

**2. Run the setup script again:**

```bash
# Re-run setup to update components
./setup-all.sh
```

**3. Update individual tools:**

```bash
# Update Homebrew packages (macOS)
brew update && brew upgrade

# Update Arch packages
sudo pacman -Syu

# Update language tools
fnm install --lts  # Node.js
pyenv update      # Python
rustup update     # Rust
```

### Migration from Previous Versions

If upgrading from an older version:

1. Backup your configurations
2. Review the CHANGELOG.md
3. Run the migration script (if available)
4. Test your development environment

## Contributing

### How to Contribute

We welcome contributions! Please follow these guidelines:

**1. Fork and Clone:**

```bash
git clone https://github.com/yourusername/dev-setup.git
cd dev-setup
git checkout -b feature/your-feature-name
```

**2. Make Changes:**

- Follow existing code style
- Test your changes thoroughly
- Update documentation if needed
- Add tests for new functionality

**3. Run Quality Checks:**

```bash
# Lint scripts
./scripts/lint.sh

# Run tests
./docker/run-tests.sh
```

**4. Submit Pull Request:**

- Clear description of changes
- Reference any related issues
- Include test results
- Update CHANGELOG.md

### Code Style Guidelines

- Use 4 spaces for indentation in shell scripts
- Follow ShellCheck recommendations
- Add comments for complex logic
- Use meaningful variable names
- Keep functions small and focused

### Reporting Issues

When reporting issues, please include:

- Operating system and version
- Shell version (`echo $SHELL && $SHELL --version`)
- Error messages and logs
- Steps to reproduce
- Expected vs actual behavior

## Troubleshooting

### Common Issues

**1. Command not found after installation**

- Solution: Restart your shell or run `source ~/.zshrc`

**2. Slow shell startup**

- Check: Run `time zsh -i -c exit` to measure
- Solution: Disable unused plugins in `.zshrc`

**3. Git performance issues**

- Run: `git maintenance start` to enable background optimization
- Check: `git config --list | grep -E "(commit|fetch|pack)"`

**4. Claude Code not working**

- Verify: `~/.claude/local/claude` exists
- Run: `claude migrate-installer` if needed
- Check: npm global path is in your PATH

### Debug Commands

```bash
# Check tool versions
./setup.sh --version-check

# Verify installations
which eza bat rg fd btop

# Test configurations
starship --version
kitty --version
claude --version

# Shell performance
for i in {1..10}; do time zsh -i -c exit; done
```

### Getting Help

1. Check logs: `~/.dev-setup.log`
2. Run in verbose mode: `./setup.sh --verbose`
3. Use dry-run to preview: `./setup.sh --dry-run`
4. Report issues: Create GitHub issue with log output

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Zinit](https://github.com/zdharma-continuum/zinit) - Fast Zsh plugin manager
- [Starship](https://starship.rs/) - Cross-platform prompt
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Color scheme
- [LazyVim](https://www.lazyvim.org/) - Neovim configuration
- All the amazing open-source tool maintainers

## Conclusion

This development environment setup provides:

- ✅ **200+ modern tools** for every development need
- ✅ **AI-powered assistance** with Claude Code integration
- ✅ **Cross-platform support** for macOS and Linux
- ✅ **Performance optimized** configurations
- ✅ **Extensive automation** for common tasks

The setup prioritizes developer experience with smart defaults, modern tools, and extensive customization while maintaining simplicity and performance.

---

**Happy Coding!** 🚀

For questions or support, please open an issue on GitHub.
