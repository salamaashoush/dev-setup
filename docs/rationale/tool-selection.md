# Tool Selection Philosophy

## Core Principles

### 1. Performance First
Every tool selected prioritizes speed and efficiency:
- **GPU Acceleration**: Kitty terminal uses GPU for rendering
- **Rust-based Tools**: ripgrep, fd, eza, bat, zoxide - all 10-100x faster than traditional alternatives
- **Lazy Loading**: Shell configuration uses lazy loading to maintain <100ms startup time
- **Native Performance**: Zed editor built in Rust for instant startup

### 2. Modern Replacements
Traditional Unix tools replaced with modern alternatives that respect current workflows:

| Traditional | Modern | Why |
|------------|---------|-----|
| ls | eza | Git integration, better colors, icons |
| cat | bat | Syntax highlighting, git integration |
| grep | ripgrep | 10-100x faster, respects .gitignore |
| find | fd | Intuitive syntax, faster, colorized |
| cd | zoxide | Learns from usage patterns |
| man | tldr | Practical examples over exhaustive docs |
| top | btop | Better visualization, mouse support |
| du | dust | Intuitive tree visualization |

### 3. Cross-Platform Consistency
Tools work identically on macOS and Linux:
- **Same configs**: Shared dotfiles between platforms
- **Same shortcuts**: Where possible, maintain muscle memory
- **Same themes**: Tokyo Night Storm everywhere
- **Platform-specific optimizations**: Without breaking compatibility

### 4. Developer Experience
Tools enhance rather than hinder workflow:
- **Fuzzy finding**: fzf integration everywhere
- **Git awareness**: Tools understand git repositories
- **Smart defaults**: Sensible out-of-box configuration
- **Extensibility**: Can grow with user needs

## Category-Specific Decisions

### Terminal Emulators

**Why Kitty?**
- Fastest terminal available (GPU accelerated)
- Cross-platform with identical features
- Extensive customization via text config
- Native image protocol support
- Low latency input handling


**Why not iTerm2?**
- macOS only - breaks cross-platform requirement
- Kitty is faster with GPU acceleration
- Text-based config better for version control

### Shell Enhancement

**Why Zsh + Zinit?**
- Zsh most compatible with existing scripts
- Zinit fastest plugin manager (lazy loading)
- Better completion system than Bash
- Maintains POSIX compatibility when needed


**Why not Oh My Zsh?**
- Too slow (adds 200-500ms to startup)
- Bloated with unused features
- Zinit allows selective loading

### File Navigation

**Why zoxide over autojump/z?**
- Written in Rust (10x faster)
- Better fuzzy matching algorithm
- Cross-shell support
- Active development

**Why Yazi for file management?**
- Blazing fast performance (written in Rust)
- Modern UI with image/video preview support
- Vim-like keybindings for efficient navigation
- Built-in file operations with progress indicators
- Extensible with Lua plugins
- Active development and growing ecosystem

### Code Editors

**Why multiple editors?**
- VS Code: Best extension ecosystem
- Zed: Fastest performance, future-focused
- Cursor: AI integration for assisted coding
- Neovim: Terminal-based, works over SSH

**Editor selection matrix:**
| Need | Choose |
|------|---------|
| Extensions | VS Code |
| Performance | Zed |
| AI Assistance | Cursor |
| Terminal/SSH | Neovim |

### Build Tools

**Why just over make?**
- Modern syntax without tabs
- Better error messages
- Cross-platform shell selection
- Parameters support

**Why keep make?**
- Still needed for many projects
- Universal compatibility
- C/C++ ecosystem standard

### Package Managers

**Language-specific choices:**
- **Node.js**: pnpm (disk efficient), bun (speed)
- **Python**: uv (fastest), poetry (projects)
- **Rust**: cargo with binstall (binary caching)
- **System**: Homebrew (macOS), yay (Arch)

## Excluded Tools & Why

### Not Included
1. **Tmux**: Kitty + Zellij provide same features with better UX
2. **Vim (classic)**: Neovim is strictly better
3. **Terraform/Vagrant**: BUSL license concerns
4. **Atuin**: Privacy concerns, adds complexity
5. **Docker Desktop (Linux)**: OrbStack/Colima lighter

### Deprecated Tools
- `ack` → Replaced by ripgrep
- `ctags` → LSP servers better
- `screen` → Zellij more modern
- `nvm` → fnm is faster

## Performance Benchmarks

### Startup Times
- Shell (zsh + zinit): <100ms
- Kitty terminal: <50ms  
- VS Code: ~2s
- Zed: <200ms
- Neovim: <100ms

### Search Performance (1GB codebase)
- grep: 8.5s
- ack: 6.2s
- ripgrep: 0.3s

### File Finding (100k files)
- find: 4.2s
- fd: 0.8s

## Future Considerations

### Watching
- **Warp Terminal**: Promising but macOS only currently
- **Helix Editor**: Modern modal editor, may replace Neovim
- **Mold Linker**: 10x faster linking for large C++ projects
- **Ruff**: Already included, will expand Python tooling

### Principles for Addition
1. Must provide 5x+ improvement over existing tool
2. Must work on both macOS and Linux
3. Must integrate with existing workflow
4. Must respect user privacy
5. Must have sustainable licensing

## User Customization

The setup is designed to be customized:
1. Tools are modular - remove what you don't need
2. Configs are documented - understand before changing  
3. Defaults are sensible - you may not need to change
4. Platform-specific sections - tweak per OS

Remember: The best tool is the one you'll actually use. This selection provides excellent defaults while remaining hackable for power users.