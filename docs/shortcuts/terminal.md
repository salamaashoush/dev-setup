# Terminal Keyboard Shortcuts

## Kitty Terminal

### Window Management
- `Ctrl+Shift+Enter` → New window
- `Ctrl+Shift+W` → Close window
- `Ctrl+Shift+]` → Next window
- `Ctrl+Shift+[` → Previous window
- `Ctrl+Shift+F` → Move window forward
- `Ctrl+Shift+B` → Move window backward
- `Ctrl+Shift+1-9` → Go to window 1-9
- `Ctrl+Shift+R` → Start resizing window

### Tab Management
- `Ctrl+Shift+T` → New tab
- `Ctrl+Shift+Q` → Close tab
- `Ctrl+Shift+Right` → Next tab
- `Ctrl+Shift+Left` → Previous tab
- `Ctrl+Shift+.` → Move tab forward
- `Ctrl+Shift+,` → Move tab backward
- `Ctrl+Shift+Alt+T` → Set tab title

### Scrolling
- `Ctrl+Shift+Up/K` → Scroll up
- `Ctrl+Shift+Down/J` → Scroll down
- `Ctrl+Shift+Page Up` → Scroll page up
- `Ctrl+Shift+Page Down` → Scroll page down
- `Ctrl+Shift+Home` → Scroll to top
- `Ctrl+Shift+End` → Scroll to bottom
- `Ctrl+Shift+H` → Show scrollback buffer
- `Ctrl+Shift+G` → Show last command output

### Splits (Layouts)
- `Ctrl+Shift+L` → Next layout
- `Cmd+Shift+D` (macOS) → Split horizontal
- `Ctrl+Cmd+D` (macOS) → Split vertical
- `Ctrl+Shift+Enter` → New window in current directory

### Font Size
- `Ctrl+Shift+Plus` → Increase font size
- `Ctrl+Shift+Minus` → Decrease font size
- `Ctrl+Shift+Backspace` → Reset font size
- `Ctrl+Shift+F6` → Set font size to 16

### Hints Mode
- `Ctrl+Shift+E` → Open URL with hints
- `Ctrl+Shift+P>F` → Select file path
- `Ctrl+Shift+P>L` → Select line
- `Ctrl+Shift+P>W` → Select word
- `Ctrl+Shift+P>H` → Select hash
- `Ctrl+Shift+P+N` → Select line number
- `Ctrl+Shift+P+Y` → Select hyperlink

### Special Functions
- `Ctrl+Shift+F11` → Toggle fullscreen
- `Ctrl+Shift+F10` → Toggle maximized
- `Ctrl+Shift+F2` → Edit config file
- `Ctrl+Shift+U` → Unicode input
- `Ctrl+Shift+Delete` → Clear terminal
- `Ctrl+Shift+Alt+S` → Show sessions

### Platform Specific (macOS)
- `Cmd+N` → New OS window
- `Cmd+W` → Close tab
- `Cmd+Enter` → Toggle fullscreen
- `Cmd+K` → Clear terminal
- `Cmd+C` → Copy
- `Cmd+V` → Paste

### Platform Specific (Linux)
- `Ctrl+C` → Copy or interrupt
- `Ctrl+V` → Paste
- `Ctrl+T` → New tab
- `Ctrl+Enter` → New window

## herdr Multiplexer

Prefix is `Ctrl+Space`. Bindings follow tmux: a tmux session is a herdr workspace, a window is a tab, a pane is a pane. Config: `~/.config/herdr/config.toml`.

### Prefix Commands
- `Prefix ?` → Help
- `Prefix d` → Detach
- `Prefix q` → Reload config
- `Prefix [` → Copy mode

### Panes
- `Prefix h` / `Alt+Enter` → Split horizontally
- `Prefix v` / `Alt+Shift+Enter` → Split vertically
- `Prefix x` / `Alt+Esc` → Close pane
- `Prefix z` → Zoom pane
- `Prefix ;` → Last pane
- `Prefix Shift+O` → Rename pane
- `Ctrl+Alt+Arrow` → Focus pane (Ghostty's config unbinds these so herdr receives them)
- `Ctrl+Alt+Shift+Arrow` → Resize pane
- `Prefix Ctrl+Arrow` → Resize mode

### Tabs
- `Prefix c` → New tab
- `Prefix r` → Rename tab
- `Prefix k` → Close tab
- `Prefix 1-9` / `Alt+1-9` → Go to tab
- `Prefix p` / `Alt+Left` → Previous tab
- `Prefix n` / `Alt+Right` → Next tab
- `Alt+Shift+Left/Right` → Move tab

### Workspaces
- `Prefix Shift+C` → New workspace
- `Prefix Shift+R` → Rename workspace
- `Prefix Shift+K` → Close workspace
- `Prefix Shift+P/N` → Previous/next workspace

## Shell Navigation (Zsh)

### History
- `Ctrl+R` → Fuzzy search history (fzf)
- `Up/Down` → Search history by the typed prefix
- `Ctrl+P` → Previous command
- `Ctrl+N` → Next command
- `Alt+.` → Insert last argument
- `!!` → Repeat last command

### Line Editing
- `Alt+Left/Right` (`Option` on macOS) → Jump words
- `Esc Esc` → Prefix the line with `sudo`
- `Ctrl+A` → Beginning of line
- `Ctrl+E` → End of line
- `Ctrl+K` → Kill to end of line
- `Ctrl+U` → Kill to beginning
- `Ctrl+W` → Kill word backward
- `Alt+D` → Kill word forward
- `Ctrl+Y` → Yank (paste)

### Directory Navigation
- `Ctrl+T` → Fuzzy find file (fzf)
- `Alt+C` → Fuzzy change directory (fzf)
- `z <pattern>` → Jump to directory (zoxide)
- `zi <pattern>` → Interactive directory jump
- `cd -` → Previous directory
- `~` → Home directory

### Job Control
- `Ctrl+Z` → Suspend current job
- `fg` → Resume job in foreground
- `bg` → Resume job in background
- `jobs` → List jobs
- `Ctrl+C` → Interrupt/kill
- `Ctrl+D` → EOF/exit

## Common Development Shortcuts

### Git Operations (lazygit)
- `lg` → Launch lazygit
- `Space` → Stage/unstage
- `c` → Commit
- `p` → Push
- `P` → Pull
- `?` → Help

### File Operations
- `eza -la` → List with details
- `bat <file>` → View with highlighting
- `fd <pattern>` → Find files
- `rg <pattern>` → Search in files

### Process Management
- `btop` → System monitor
- `procs` → Process list
- `Ctrl+\` → Quit process
- `kill -9 <pid>` → Force kill

## Quick Tips

1. **Multi-cursor in Terminal**: Use Kitty's broadcast mode
   - `Ctrl+Shift+Alt+I` → Start broadcast
   - `Ctrl+Shift+Alt+O` → Stop broadcast

2. **Quick Command Execution**:
   - `$(!!)` → Execute last command in subshell
   - `sudo !!` → Run last command with sudo
   - `^old^new` → Replace in last command

3. **Navigation Efficiency**:
   - Enable vi mode: `set -o vi` in shell
   - Use `pushd`/`popd` for directory stack
   - Create aliases for common paths

4. **Session Management**:
   - Save Kitty layout: `Ctrl+Shift+Alt+S`
   - Use herdr sessions for projects (`hrs <name>`)
   - Configure direnv for auto-environment

5. **Copy/Paste Workflow**:
   - Select text to copy (Kitty)
   - Middle-click to paste (Linux)
   - Use system clipboard integration