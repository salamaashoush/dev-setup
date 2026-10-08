# Mac Dev Setup - Quick Reference

## 🚀 Most Used Commands

### Navigation
```bash
z project          # Jump to project directory
fd README          # Find files
rg "TODO"          # Search in files  
eza -la           # List files with git status
```

### Git
```bash
lg                # LazyGit UI
gs                # Git status
gc -m "message"   # Commit
gp                # Push
```

### Development
```bash
zed .             # Open Zed
pnpm dev          # Start dev server
docker-compose up # Start containers
topgrade          # Update everything
```

## ⌨️ Essential Shortcuts

### macOS
| Action | Shortcut |
|--------|----------|
| App Launcher (Bolt) | `Cmd+Space` or `Opt+Space` |
| Terminal | `Cmd+Opt+T` |
| Zed | `Cmd+Opt+C` |
| Clipboard History | `Cmd+Space`, then "Clipboard History" |
| Window Left/Right | `Ctrl+Opt+←→` |

### Linux (KDE)
| Action | Shortcut |
|--------|----------|
| App Launcher | `Alt+Space` |
| Terminal | `Ctrl+Alt+T` |
| Zed | `Ctrl+Alt+C` |
| Clipboard History | `Alt+Shift+C` |
| Window Left/Right | `Meta+←→` |

### Terminal (Kitty)
| Action | Shortcut |
|--------|----------|
| New Tab | `Ctrl+Shift+T` |
| Split Horizontal | `Cmd/Ctrl+Shift+D` |
| Navigate Panes | `Ctrl+Shift+Arrow` |
| Zoom Toggle | `Ctrl+Shift+Z` |

### Editor (Zed)
| Action | Shortcut |
|--------|----------|
| Command Palette | `Cmd/Ctrl+Shift+P` |
| Quick Open | `Cmd/Ctrl+P` |
| Select Next Occurrence | `Cmd/Ctrl+D` |
| Toggle Bottom Dock | `Cmd/Ctrl+J` |

## 📦 Key Tools Installed

### Terminal & Shell
- **kitty** - GPU-accelerated terminal
- **zsh + zinit** - Fast shell with plugins
- **starship** - Cross-platform prompt
- **herdr** - Agent multiplexer (prefix `Ctrl+Space`, `cheat herdr` for bindings)

### CLI Essentials
- **eza** - Better ls
- **bat** - Better cat
- **ripgrep** - Better grep
- **fd** - Better find
- **fzf** - Fuzzy finder
- **zoxide** - Smart cd

### Development
- **Zed** - Primary editor
- **Neovim + LazyVim** - Terminal editor
- **lazygit** - Git UI
- **docker** - Containers
- **mise** - Runtimes, CLI tools, and Claude Code (`mise up` to upgrade)

### Productivity
- **Bolt/Rofi** - Launcher
- **Rectangle** - Window management
- **btop** - System monitor
- **topgrade** - Universal updater

## 🎯 Common Workflows

### Start New Project
```bash
mkdir project && cd project
git init

# Node.js
pnpm init && pnpm add -D typescript

# Python
pyvenv && pyactivate   # uv venv, then activate .venv

# Rust
cargo init

# Then
zed .  # Open in editor
```

### Quick File Search
```bash
# Find file by name
fd component.tsx

# Find text in files
rg "function.*export"

# Interactive search
fd -e js | fzf | xargs zed
```

### System Maintenance
```bash
# Update everything
topgrade

# Check disk usage
dust

# Monitor resources
btop
```

### Multiplayer Gaming
```bash
gamenet check              # Diagnose firewall + router + ISP
gamenet check 25565        # ...end-to-end for one port
sudo game-firewall         # Open ufw for game hosting
gamenet maps               # List UPnP port mappings
```

### Hardware Tuning (AMD X3D / CachyOS)
```bash
x3d-mode                   # Show current CCD preference
x3d-mode cache             # Gaming - prefer V-Cache CCD
x3d-mode frequency         # Compiling - prefer high-clock CCD
scx-manager                # Pick a sched_ext scheduler (GUI)
sudo scx_lavd              # Latency-tuned scheduler for gaming
```

## 🔧 Configuration Locations

- Shell: `~/.zshrc`
- Kitty: `~/.config/kitty/kitty.conf`
- Git: `~/.gitconfig`
- Zed: `~/.config/zed/settings.json`
- Starship: `~/.config/starship.toml`
- herdr: `~/.config/herdr/config.toml`
- mise: `~/.config/mise/conf.d/dev-setup.toml`

## 💡 Pro Tips

1. **Use fuzzy finders**: Press `Ctrl+R` for command history
2. **Learn aliases**: Type `alias` to see all
3. **Tab completion**: Works everywhere
4. **Multi-cursor**: Hold `Alt` and click in editors
5. **Quick switch**: `Cmd/Alt+Tab` between apps

## 🆘 Help Commands

```bash
tldr <command>     # Quick examples
man <command>      # Full manual
<command> --help   # Built-in help
type <command>     # Show command location
```

## 🔗 Resources

- Full docs: `/docs/README.md`
- Shortcuts: `/docs/shortcuts/`
- Troubleshooting: `/docs/troubleshooting/`
- Configurations: `/docs/configurations/`