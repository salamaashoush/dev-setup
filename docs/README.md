# Mac Dev Setup - Comprehensive Documentation

This documentation provides a complete guide to all tools, configurations, and keyboard shortcuts in the Mac Dev Setup environment.

## Table of Contents

### 📦 [Tools Documentation](./tools/)
- [Terminal & Shell Tools](./tools/terminal-shell.md)
- [Development Tools](./tools/development.md)
- [Productivity Tools](./tools/productivity.md)
- [System Tools](./tools/system.md)
- [Network Tools](./tools/network.md)
- [Gaming Network](./tools/gaming-network.md)
- [Game Development](./tools/game-development.md)
- [CachyOS & Hardware Tuning](./tools/cachyos-hardware.md)
- [Container & Cloud Tools](./tools/containers-cloud.md)

### ⌨️ [Keyboard Shortcuts](./shortcuts/)
- [Global System Shortcuts](./shortcuts/global-system.md)
- [Terminal Shortcuts](./shortcuts/terminal.md)
- [Editor Shortcuts](./shortcuts/editors.md)
- [Window Management](./shortcuts/window-management.md)
- [Application Launchers](./shortcuts/launchers.md)
- [Development Workflow](./shortcuts/development-workflow.md)

### ⚙️ [Configurations](./configurations/)
- [Shell Configuration](./configurations/shell.md)
- [Terminal Emulators](./configurations/terminals.md)
- [Git Configuration](./configurations/git.md)
- [Editor Configurations](./configurations/editors.md)
- [System Optimizations](./configurations/system.md)

### 🎯 [Design Rationale](./rationale/)
- [Tool Selection Philosophy](./rationale/tool-selection.md)
- [Performance Optimizations](./rationale/performance.md)
- [Cross-Platform Considerations](./rationale/cross-platform.md)
- [Theme & UI Consistency](./rationale/theme-consistency.md)

### 🔧 [Troubleshooting](./troubleshooting/)
- [Common Issues](./troubleshooting/common-issues.md)
- [Platform-Specific Problems](./troubleshooting/platform-specific.md)
- [Performance Tuning](./troubleshooting/performance.md)

## Quick Reference

### Most Important Shortcuts

#### macOS
- `Cmd+Space` → Raycast (App Launcher)
- `Cmd+Opt+T` → Open Kitty Terminal
- `Cmd+Opt+C` → Open VS Code
- `Cmd+Opt+V` → Clipboard History

#### Linux (KDE Plasma)
- `Alt+Space` → Rofi (App Launcher)
- `Ctrl+Alt+T` → Open Terminal (Kitty)
- `Ctrl+Alt+C` → Open VS Code
- `Alt+Shift+C` → Clipboard History

### Essential Commands

```bash
# Update all tools
topgrade

# Quick directory navigation
z <directory>  # Jump to frequently used directories

# Enhanced file operations
eza -la       # Better ls with git integration
bat <file>    # Better cat with syntax highlighting
fd <pattern>  # Fast file search
rg <pattern>  # Fast text search (ripgrep)

# Git workflow
lazygit       # Interactive git UI
git delta     # Enhanced git diffs
```

### Key Features

1. **Unified Tokyo Night Storm Theme** - Consistent dark theme across all tools
2. **GPU-Accelerated Terminals** - Kitty with optimized rendering
3. **Smart Tool Selection** - Modern alternatives to traditional Unix tools
4. **Cross-Platform Support** - Works seamlessly on macOS and Arch Linux
5. **Developer-First Workflow** - Optimized for coding productivity

## Getting Started

1. Review the [Tool Selection Philosophy](./rationale/tool-selection.md)
2. Check platform-specific [Global System Shortcuts](./shortcuts/global-system.md)
3. Configure your preferred [Terminal](./configurations/terminals.md)
4. Set up your [Development Environment](./tools/development.md)

## Contributing

When adding new tools or configurations:
1. Update the relevant documentation
2. Add keyboard shortcuts to the appropriate shortcuts file
3. Document the rationale for the addition
4. Test on both macOS and Linux platforms