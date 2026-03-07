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

## Zellij Multiplexer

### Mode Switching
- `Ctrl+P` → Pane mode
- `Ctrl+T` → Tab mode
- `Ctrl+N` → Resize mode
- `Ctrl+S` → Scroll mode
- `Ctrl+O` → Session mode
- `Ctrl+Q` → Quit mode

### In Pane Mode (Ctrl+P)
- `n` → New pane
- `d` → Split down
- `r` → Split right
- `x` → Close pane
- `f` → Toggle fullscreen
- `hjkl` → Navigate panes
- `Shift+hjkl` → Move pane
- `p` → Next pane
- `c` → Rename pane

### In Tab Mode (Ctrl+T)
- `n` → New tab
- `x` → Close tab
- `r` → Rename tab
- `s` → Sync tab
- `Tab` → Toggle tab
- `hjkl` → Navigate tabs
- `1-9` → Go to tab

### In Resize Mode (Ctrl+N)
- `hjkl` → Resize current pane
- `Shift+hjkl` → Resize more
- `=` → Equalize panes
- `+/-` → Increase/decrease

## Shell Navigation (Zsh)

### History
- `Ctrl+R` → Fuzzy search history (fzf)
- `Ctrl+P` → Previous command
- `Ctrl+N` → Next command
- `Alt+.` → Insert last argument
- `!!` → Repeat last command

### Line Editing
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
   - Use zellij sessions for projects
   - Configure direnv for auto-environment

5. **Copy/Paste Workflow**:
   - Select text to copy (Kitty)
   - Middle-click to paste (Linux)
   - Use system clipboard integration