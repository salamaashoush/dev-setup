# Terminal & Shell Tools Documentation

## Terminal Emulators

### Kitty
**Description**: GPU-accelerated terminal emulator with extensive customization  
**Category**: Terminal  
**Installed**: Both platforms  
**Configuration**: `configs/kitty.conf`

**Key Features**:
- GPU acceleration for smooth scrolling and rendering
- Ligature support with CaskaydiaCove Nerd Font
- Tokyo Night Storm theme
- Background blur and transparency
- Image protocol support for inline images
- Session management and layouts

**Why Kitty?**
- Fastest terminal rendering performance
- Cross-platform consistency
- Extensive keyboard shortcuts
- Native image viewing support
- Low latency input handling


## Shell & Core Tools

### Zsh
**Description**: Advanced shell with powerful features  
**Essential**: Yes  
**Configuration**: `configs/zshrc`

**Enhancements**:
- Zinit plugin manager for fast startup
- Syntax highlighting
- Auto-suggestions
- History substring search
- Directory jumping with zoxide

### Starship
**Description**: Cross-platform prompt with contextual information  
**Configuration**: `configs/starship.toml`  
**Install**: `curl -sS https://starship.rs/install.sh | sh`

**Features**:
- Git status integration
- Language version display
- Command duration
- Custom modules
- Tokyo Night colors

## Essential CLI Tools

### eza (ls replacement)
**Description**: Modern ls with Git integration  
**Essential**: Yes  
**Usage**: 
```bash
eza -la          # Long format with hidden files
eza --tree       # Tree view
eza --git-ignore # Respect .gitignore
```

**Why eza?**
- Git status in file listings
- Better default colors
- Tree view support
- Icons support

### bat (cat replacement)
**Description**: cat with syntax highlighting  
**Essential**: Yes  
**Usage**:
```bash
bat file.py           # View with syntax highlighting
bat -A file           # Show non-printable characters
bat --plain file      # Plain output (like cat)
```

**Why bat?**
- Syntax highlighting for 150+ languages
- Git integration shows modifications
- Line numbers and paging
- Theme support (Tokyo Night)

### ripgrep (grep replacement)
**Description**: Extremely fast text search  
**Essential**: Yes  
**Command**: `rg`  
**Usage**:
```bash
rg pattern                    # Search in current directory
rg -i pattern                 # Case insensitive
rg -A 3 -B 3 pattern         # Show context
rg --type py pattern         # Search only Python files
```

**Why ripgrep?**
- 10-100x faster than grep
- Respects .gitignore by default
- Smart case sensitivity
- Better Unicode support

### fd (find replacement)
**Description**: Fast and user-friendly find  
**Essential**: Yes  
**Usage**:
```bash
fd pattern              # Find files/directories
fd -e py               # Find by extension
fd -H pattern          # Include hidden files
fd -E node_modules     # Exclude paths
```

**Why fd?**
- Intuitive syntax
- Colorized output
- Parallel directory traversal
- .gitignore awareness

### fzf
**Description**: Command-line fuzzy finder  
**Essential**: Yes  
**Configuration**: Set in zshrc with Tokyo Night colors

**Key Bindings**:
- `Ctrl+R` → Fuzzy search command history
- `Ctrl+T` → Fuzzy find files
- `Alt+C` → Fuzzy change directory
- `**<Tab>` → Trigger completion

**Why fzf?**
- Interactive filtering for any list
- Integrates with shell history
- Preview window support
- Vim integration available

### zoxide
**Description**: Smarter cd that learns your habits  
**Essential**: Yes  
**Usage**:
```bash
z proj        # Jump to ~/Projects/my-project
zi proj       # Interactive selection
zq proj       # Query database
```

**Why zoxide?**
- Learns from your navigation patterns
- Fuzzy matching
- 10x faster than autojump/z
- Cross-shell support

### direnv
**Description**: Load/unload environment variables by directory  
**Essential**: Yes  
**Usage**: Create `.envrc` file in project root

**Why direnv?**
- Automatic environment switching
- Project-specific tool versions
- Security through allow/deny
- Shell integration

## Terminal Multiplexers

### Zellij
**Description**: Modern terminal multiplexer  
**Category**: Multiplexer

**Advantages over tmux**:
- Intuitive default keybindings
- Floating panes
- Better mouse support
- Built-in layouts
- WebAssembly plugin system

**Key Bindings**:
- `Ctrl+P` → Pane mode
- `Ctrl+T` → Tab mode  
- `Ctrl+N` → Resize mode
- `Ctrl+S` → Scroll mode

## File Manager

### Yazi
**Description**: Blazing fast terminal file manager written in Rust  
**Usage**: `yazi` or `y` (with cd-on-quit integration)

**Key Features**:
- Lightning fast performance
- Image and video preview support
- Vim-like keybindings
- Built-in file operations with progress
- Tab support for multiple directories
- Extensible with Lua plugins

**Essential Key Bindings**:
- `h/j/k/l` → Navigate (left/down/up/right)
- `Enter` → Open file/enter directory
- `q` → Quit
- `y` → Yank (copy) files
- `x` → Cut files
- `p` → Paste files
- `d` → Delete files
- `r` → Rename
- `Space` → Toggle selection
- `.` → Toggle hidden files
- `/` → Search
- `!` → Open shell in directory

**Advanced Features**:
- `Tab` → Create new tab
- `1-9` → Switch to tab
- `[/]` → Previous/next tab
- `f` → Quick filter
- `s` → Search with fd
- `S` → Search contents with ripgrep

## Shell Enhancements

### tldr
**Description**: Simplified man pages with examples  
**Usage**: `tldr <command>`

**Why tldr?**
- Practical examples
- Common use cases
- Concise information
- Community maintained

### noti
**Description**: Monitor long-running commands  
**Usage**: `long-command && noti`

**Why noti?**
- Desktop notifications
- Sound alerts
- Cross-platform
- Minimal setup

### vivid
**Description**: LS_COLORS generator  
**Usage**: `export LS_COLORS="$(vivid generate tokyo-night)"`

**Why vivid?**
- Theme-based color generation
- Consistent file type colors
- Easy customization