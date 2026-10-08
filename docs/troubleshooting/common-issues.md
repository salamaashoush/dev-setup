# Common Issues & Solutions

## Installation Problems

### Installer

**Issue**: `bootstrap.sh` exits with "stdin is not a terminal"
```bash
# The installer prompts, so run it with bash -c instead of piping it into bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/salamaashoush/dev-setup/main/bootstrap.sh)"
```

**Issue**: Packages listed as failed at the end of the install
```bash
mise install   # Retry the tools that come from mise
./install.sh   # Safe to re-run; retries Homebrew/pacman packages
```

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

# 4. Rebuild the cached tool init scripts (brew, mise, starship, zoxide, direnv, fzf, vivid)
rm -rf ~/.cache/zsh
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
mise ls                  # Runtimes and CLI tools from mise
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

### herdr

**Issue**: Config changes or sessions not showing up
```bash
herdr status                  # Client and running server status
herdr session list            # Named sessions
herdr server reload-config    # Re-read ~/.config/herdr/config.toml
herdr server stop             # Stop the running server, e.g. after mise upgrades herdr
```

**Issue**: `Ctrl+Alt+Arrow` does not focus panes

Ghostty's Linux defaults bind these keys to split navigation. `configs/ghostty.conf` unbinds them; if you keep your own Ghostty config, add the same `keybind = ctrl+alt+left=unbind` lines for each arrow.

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

### Zed

**Issue**: Default theme or icons instead of Tokyo Night Storm

The theme and icons come from the `tokyo-night` and `catppuccin-icons` extensions, which Zed installs on first launch. Until that download finishes Zed shows its defaults; check progress with `zed: extensions` in the command palette.

**Issue**: `zed: command not found` on Arch
```bash
# Arch ships the CLI as zeditor; install.sh links zed to it
ln -sf "$(command -v zeditor)" ~/.local/bin/zed
```

### Neovim

**Issue**: Plugins not loading
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Reinstall plugins (LazyVim uses lazy.nvim)
nvim --headless "+Lazy! sync" +qa
```

## Development Tool Issues

### Node.js/mise

**Issue**: "node: command not found" (or any other tool from mise)
```bash
# mise must be activated in ~/.zshrc (configs/zshrc does this)
eval "$(mise activate zsh)"

# Check activation, then install anything missing from the mise config
mise doctor
mise install
```

**Issue**: Global packages not found
```bash
# Check npm prefix
npm config get prefix

# Fix PATH
export PATH="$(npm config get prefix)/bin:$PATH"
```

### Python

**Issue**: "No module named X"
```bash
# Check virtual environment
which python
uv pip list

# Create and activate a venv
uv venv && source .venv/bin/activate
```

### Rust

**Issue**: "cargo: command not found"
```bash
# Rust comes from mise; check where cargo resolves
mise which cargo

# Reinstall if needed
mise install rust
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