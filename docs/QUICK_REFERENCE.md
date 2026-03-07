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
code .            # Open VS Code
pnpm dev          # Start dev server
docker-compose up # Start containers
topgrade          # Update everything
```

## ⌨️ Essential Shortcuts

### macOS
| Action | Shortcut |
|--------|----------|
| App Launcher | `Cmd+Space` |
| Terminal | `Cmd+Opt+T` |
| VS Code | `Cmd+Opt+C` |
| Clipboard History | `Cmd+Opt+V` |
| Window Left/Right | `Ctrl+Opt+←→` |

### Linux (KDE)
| Action | Shortcut |
|--------|----------|
| App Launcher | `Alt+Space` |
| Terminal | `Ctrl+Alt+T` |
| VS Code | `Ctrl+Alt+C` |
| Clipboard History | `Alt+Shift+C` |
| Window Left/Right | `Meta+←→` |

### Terminal (Kitty)
| Action | Shortcut |
|--------|----------|
| New Tab | `Ctrl+Shift+T` |
| Split Horizontal | `Cmd/Ctrl+Shift+D` |
| Navigate Panes | `Ctrl+Shift+Arrow` |
| Zoom Toggle | `Ctrl+Shift+Z` |

### Editor (VS Code)
| Action | Shortcut |
|--------|----------|
| Command Palette | `Cmd/Ctrl+Shift+P` |
| Quick Open | `Cmd/Ctrl+P` |
| Multi-cursor | `Cmd/Ctrl+D` |
| Terminal Toggle | `Cmd/Ctrl+J` |

## 📦 Key Tools Installed

### Terminal & Shell
- **kitty** - GPU-accelerated terminal
- **zsh + zinit** - Fast shell with plugins
- **starship** - Cross-platform prompt
- **zellij** - Modern multiplexer

### CLI Essentials
- **eza** - Better ls
- **bat** - Better cat
- **ripgrep** - Better grep
- **fd** - Better find
- **fzf** - Fuzzy finder
- **zoxide** - Smart cd

### Development
- **VS Code** - Primary editor
- **Zed** - Fast alternative
- **Neovim** - Terminal editor
- **lazygit** - Git UI
- **docker** - Containers
- **fnm** - Node manager
- **uv** - Python package manager

### Productivity
- **Raycast/Rofi** - Launcher
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
uv venv && source .venv/bin/activate

# Rust
cargo init

# Then
code .  # Open in editor
```

### Quick File Search
```bash
# Find file by name
fd component.tsx

# Find text in files
rg "function.*export"

# Interactive search
fd -e js | fzf | xargs code
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

## 🔧 Configuration Locations

- Shell: `~/.zshrc`
- Kitty: `~/.config/kitty/kitty.conf`
- Git: `~/.gitconfig`
- VS Code: `~/.config/Code/User/settings.json`
- Starship: `~/.config/starship.toml`

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