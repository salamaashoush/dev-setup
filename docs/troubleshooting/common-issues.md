# Common Issues & Solutions

## Installation Problems

### Homebrew (macOS)

**Issue**: "Permission denied" during installation
```bash
# Fix: Reset Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew
```

**Issue**: "No formulae found" 
```bash
# Fix: Update and upgrade
brew update
brew upgrade
brew doctor  # Check for issues
```

### AUR/Yay (Arch Linux)

**Issue**: "Package not found"
```bash
# Fix: Update package database
yay -Syy
yay -Syu  # Full system update
```

**Issue**: Build failures
```bash
# Fix: Install base development tools
sudo pacman -S base-devel
```

## Shell Issues

### Slow Shell Startup

**Diagnosis**:
```bash
# Time shell startup
time zsh -i -c exit

# Profile startup
zsh -xvs 2>&1 | ts -i "%.s" > startup.log
```

**Common causes**:
1. Too many plugins
2. Synchronous operations
3. Missing command caching

**Solutions**:
```bash
# 1. Lazy load plugins
zinit ice wait lucid
zinit load plugin-name

# 2. Compile zcompdump
rm -f ~/.zcompdump*
compinit
zcompile ~/.zcompdump

# 3. Check for slow commands
for i in ~/.config/zsh/*; do
  echo "Sourcing $i"
  time source $i
done
```

### Command Not Found

**Check PATH**:
```bash
echo $PATH | tr ':' '\n' | sort
which command-name
```

**Common fixes**:
```bash
# Reload shell config
source ~/.zshrc
exec zsh

# Check installation
brew list | grep command  # macOS
yay -Qs command          # Arch

# Platform-specific paths
export PATH="/opt/homebrew/bin:$PATH"  # M1 Mac
export PATH="/usr/local/bin:$PATH"     # Intel Mac
```

## Terminal Issues

### Kitty

**Issue**: Fonts not displaying correctly
```bash
# Fix: Clear font cache
kitty +runpy 'from kitty.fonts import clear_font_cache; clear_font_cache()'

# Verify font installation
kitty +list-fonts | grep -i cascadia
```

**Issue**: GPU rendering issues
```conf
# Edit ~/.config/kitty/kitty.conf
# Disable GPU rendering temporarily
draw_strategy classic
```

**Issue**: SSH connection problems
```bash
# Fix: Generate terminfo
kitty +runpy 'from kitty.terminfo import generate_terminfo; print(generate_terminfo())' > /tmp/kitty.terminfo
tic -x -o ~/.terminfo /tmp/kitty.terminfo

# Copy to remote
kitty +kitten ssh user@host
```

### Zellij

**Issue**: Sessions not persisting
```bash
# Check session location
zellij --help | grep session
zellij ls  # List sessions

# Fix permissions
chmod 700 ~/.cache/zellij
```

## Git Issues

### SSH Keys

**Issue**: "Permission denied (publickey)"
```bash
# Check SSH agent
ssh-add -l

# Add key
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
```

### GPG Signing

**Issue**: "Cannot sign commit"
```bash
# Check GPG
gpg --list-secret-keys

# Fix TTY
export GPG_TTY=$(tty)

# Test signing
echo "test" | gpg --clearsign
```

## Editor Issues

### VS Code

**Issue**: Extensions not loading
```bash
# Clear extension cache
rm -rf ~/.vscode/extensions/*
code --list-extensions  # Verify

# Reinstall extensions
code --install-extension extension-id
```

**Issue**: Terminal integration broken
```json
// settings.json
{
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.defaultProfile.linux": "zsh",
  "terminal.integrated.fontFamily": "CaskaydiaCove NF"
}
```

### Neovim

**Issue**: Plugins not loading
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Reinstall plugins
nvim +PlugInstall +qall  # Vim-plug
nvim +PackerSync        # Packer
```

## Development Tool Issues

### Node.js/fnm

**Issue**: "fnm: command not found"
```bash
# Add to ~/.zshrc
eval "$(fnm env --use-on-cd)"

# Verify installation
curl -fsSL https://fnm.vercel.app/install | bash
```

**Issue**: Global packages not found
```bash
# Check npm prefix
npm config get prefix

# Fix PATH
export PATH="$(npm config get prefix)/bin:$PATH"
```

### Python/uv

**Issue**: "No module named X"
```bash
# Check virtual environment
which python
python -m pip list

# Activate venv
source .venv/bin/activate  # or
uv venv && source .venv/bin/activate
```

### Rust

**Issue**: "cargo: command not found"
```bash
# Add to PATH
source "$HOME/.cargo/env"

# Reinstall if needed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## System Performance

### High CPU Usage

**Identify culprit**:
```bash
btop  # Interactive view
ps aux | sort -nrk 3,3 | head -n 10  # Top CPU
```

**Common causes**:
- Indexing services
- Language servers
- File watchers

### High Memory Usage

**Check memory**:
```bash
free -h  # Linux
vm_stat  # macOS

# Find memory hogs
ps aux | sort -nrk 4,4 | head -n 10
```

**Solutions**:
- Limit language server instances
- Reduce browser tabs
- Clear caches

## Platform-Specific Issues

### macOS

**Issue**: "xcrun: error"
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

**Issue**: Quarantine attributes
```bash
# Remove quarantine
xattr -cr /Applications/AppName.app
```

### Linux (Arch/KDE)

**Issue**: Wayland compatibility
```bash
# Force X11 for problematic apps
env GDK_BACKEND=x11 application-name

# Check session type
echo $XDG_SESSION_TYPE
```

**Issue**: Audio not working
```bash
# Restart PipeWire
systemctl --user restart pipewire
systemctl --user restart pipewire-pulse
```

## Multiplayer Gaming Issues

Run `gamenet check <port>` first — it isolates which of the three layers is broken
(host firewall, router, ISP) and prints the fix. See
[Gaming Network](../tools/gaming-network.md) for the full explanation.

**Issue**: Cannot host a game — peers cannot connect, lobby is not advertised online

```bash
# ufw defaults to dropping all inbound connections
sudo game-firewall
```

**Issue**: `upnpc -l` says "No IGD UPnP Device found" even though UPnP is enabled on the router

This is the most confusing failure in the whole setup, and the order matters.
UPnP discovery sends a multicast `M-SEARCH`; the router replies **unicast**.
Conntrack cannot match that reply to the multicast request, so `ufw` drops it —
UPnP looks dead even when the router is configured correctly.

```bash
# Fix the host firewall FIRST, then re-test the router
sudo game-firewall
gamenet check
```

**Issue**: Game works on LAN but not over the internet

```bash
gamenet check <port>
```

If it reports CGNAT (a public IP in `100.64.0.0/10`), port forwarding cannot work
at all. Use a tunnel (Tailscale, playit.gg) or request a real IPv4 from the ISP.

**Issue**: Hosting worked, then broke about a week later

A manually added UPnP mapping carries a finite lease and expires. Enable UPnP
inside the game so it re-maps on every launch, or re-add it:

```bash
gamenet map <port> tcp
```

**Issue**: A container port is reachable even though `ufw` denies it

Docker and k3s write their own iptables rules and bypass `ufw`. This is expected —
`ufw` does not govern published container ports.

## Quick Fixes Reference

```bash
# Universal "turn it off and on again"
exec zsh                    # Reload shell
kitty +runpy 'reload()'     # Reload Kitty
source ~/.zshrc             # Reload config
brew services restart X     # Restart service (macOS)
systemctl --user restart X  # Restart service (Linux)

# Clear caches
rm -rf ~/.cache/*
brew cleanup
yay -Scc

# Update everything
topgrade

# Check system health
brew doctor        # macOS
yay -Syu          # Arch
```

## Getting Help

1. **Check logs**:
   - `~/.local/share/` for app logs
   - `journalctl --user` (Linux)
   - `Console.app` (macOS)

2. **Debug mode**:
   - `--verbose` or `-v` flags
   - `DEBUG=* command`
   - `set -x` in shell scripts

3. **Community**:
   - Tool-specific GitHub issues
   - Stack Overflow
   - Reddit: r/zsh, r/neovim, etc.