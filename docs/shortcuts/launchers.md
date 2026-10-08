# Application Launcher Shortcuts

## Bolt (macOS)

[Bolt](https://github.com/salamaashoush/bolt) is a native macOS launcher (macOS 15 or later). `install.sh` clones it to `~/.local/share/bolt` and runs `make install` as its last step, building with Swift 6.2 from the Command Line Tools into `/Applications/Bolt.app`. The first build creates a self-signed signing certificate: approve the prompt to trust it and choose "Always Allow" for codesign, and later builds sign without asking. `install.sh` also turns off Spotlight's `Cmd+Space` so Bolt can take it.

### Core Navigation
- `Cmd+Space` / `Opt+Space` → Show or hide Bolt
- `Up/Down`, `Ctrl+N/P`, `Ctrl+J/K` → Move selection
- `Enter` → Primary action
- `Cmd+Enter` → Secondary action
- `Opt+Enter` → Third action
- `Cmd+K` → Action list for the selected result
- `Cmd+1-9` → Run the nth result
- `Tab` → Complete the query with the selected result
- `Cmd+Delete` → Clear the query
- `Cmd+,` → Settings (`~/Library/Application Support/Bolt/config.json`)
- `Cmd+W` / `Esc` → Close (`Esc` clears a non-empty query first)

### Global Hotkeys
- `Cmd+Shift+H` → Record a global hotkey for the selected command; the command then runs system-wide without opening Bolt

### Built-in Commands
- **Clipboard History**: searchable; paste, copy, pin, delete
- **Window management**: halves, thirds, maximize, center, and more (needs Accessibility)
- **Snippets**: reusable text from `snippets.json`, pasted into the app you came from
- **Quicklinks**: `gh <query>` searches GitHub, `g <query>` searches Google
- **File search**: Spotlight search under your home directory; `content:` and `kind:` narrow it

## Rofi (Linux)

### Main Launcher
- `Alt+Space` → Open Rofi (main)
- `Meta` → Open Rofi (alternative)
- `Alt+F1` → Open Rofi (alternative)
- `Esc` → Close
- `Enter` → Launch selected
- `Shift+Enter` → Launch in terminal

### Navigation
- `↑↓` or `Ctrl+P/N` → Navigate items
- `Tab` → Next mode
- `Shift+Tab` → Previous mode
- `Ctrl+Space` → Multi-select
- `PgUp/PgDn` → Page navigation

### Search & Filter
- Start typing → Filter results
- `Ctrl+L` → Clear search
- `!` → Exclude pattern
- `^` → Start of line
- `$` → End of line

### Rofi Modes (Alt+Space then)
- `Shift+Tab` → Switch between:
  - `drun` → Desktop applications
  - `run` → All executables
  - `window` → Window switcher
  - `ssh` → SSH connections

### Custom Menus

**Clipboard History** (`Alt+Shift+C`):
- `Enter` → Paste selection
- `Ctrl+C` → Copy to clipboard
- `Delete` → Remove from history

**Power Menu** (`Alt+Shift+P`):
- Options:
  - `Lock` → Lock screen
  - `Logout` → End session
  - `Reboot` → Restart
  - `Shutdown` → Power off
  - `Suspend` → Sleep

**Developer Menu** (`Alt+Shift+D`):
- Quick access to:
  - Project directories
  - Development servers
  - Database connections
  - Docker containers

**Calculator** (`Alt+Shift+=`):
- Type expression → See result
- `Enter` → Copy result
- Supports: `+`, `-`, `*`, `/`, `^`, `sqrt()`, `sin()`, etc.

**Emoji Picker** (`Alt+Shift+E`):
- Type to search emoji
- `Enter` → Insert emoji
- Shows Unicode names

**Web Search** (`Alt+Shift+W`):
- Type query
- Select search engine:
  - Google
  - DuckDuckGo
  - GitHub
  - StackOverflow

**Screenshot** (`Alt+Shift+S`):
- Options:
  - `Screen` → Full screen
  - `Window` → Select window
  - `Region` → Select area
  - `Screen (5s)` → Delayed capture

**Window Switcher** (`Alt+Shift+Tab`):
- Enhanced window switching
- Shows window previews
- Groups by application

### Rofi Configuration

**Theme Selection**:
```bash
rofi-theme-selector  # Interactive theme picker
```

**Custom Keybindings** (in `~/.config/rofi/config.rasi`):
```
configuration {
  kb-row-up: "Up,Control+p";
  kb-row-down: "Down,Control+n";
  kb-accept-entry: "Return,Control+m";
  kb-remove-char-back: "BackSpace,Shift+BackSpace";
}
```

## KRunner (KDE - Alt+F2)

### Basic Usage
- `Alt+F2` → Open KRunner
- Type to search
- `↑↓` → Navigate results
- `Enter` → Execute
- `Esc` → Close

### Search Categories
- Applications
- Files and folders
- Bookmarks
- Calculator
- Unit converter
- Dictionary
- System commands

### Special Syntax
- `=2+2` → Force calculator mode
- `spell:word` → Spell check
- `define:word` → Dictionary
- `5 USD in EUR` → Currency conversion
- `10 meters in feet` → Unit conversion
- `kill <process>` → Kill process
- `man <command>` → Open manual

### Runner Plugins
- Enable/disable in System Settings → KRunner
- Popular plugins:
  - Browser bookmarks
  - Browser history
  - SSH connections
  - Virtual desktops
  - Window list

## Quick Tips

### Efficiency Hacks

1. **Abbreviations**:
   - Bolt ranks by fuzzy match and frecency
   - Rofi weights frequently used items
   - Type minimum unique characters

2. **Direct Actions**:
   - Calculator: Just type math
   - Conversions: Type naturally
   - Definitions: `define` prefix

3. **Keyboard-Only Navigation**:
   - Never use mouse in launchers
   - Learn Tab/Shift+Tab navigation
   - Use Ctrl+Number for quick select

### Custom Shortcuts

**Bolt**:
- Select a command and press `Cmd+Shift+H` to give it a global hotkey

**Rofi Scripts** (`~/.config/rofi/scripts/`):
```bash
#!/usr/bin/env bash
# Custom menu example
options="Option 1\nOption 2\nOption 3"
selected=$(echo -e "$options" | rofi -dmenu -p "Choose:")
case $selected in
    "Option 1") command1 ;;
    "Option 2") command2 ;;
    "Option 3") command3 ;;
esac
```

### Integration Tips

1. **Browser Integration**:
   - Bolt: quicklinks with `{query}` templates in `quicklinks.json`
   - Rofi: Firefox/Chrome bookmark scripts

2. **Password Managers**:
   - Bolt: clipboard history skips entries password managers mark concealed or transient
   - Rofi: `rofi-pass` for pass

3. **Project Switching**:
   - Create scripts for common projects
   - Include git status in preview
   - Auto-open in preferred editor

## Troubleshooting

### Bolt Not Opening
- `Cmd+Space` does nothing: Spotlight still holds it. Turn it off in System Settings > Keyboard > Keyboard Shortcuts > Spotlight, or use `Opt+Space`
- Window commands do nothing: grant Accessibility in System Settings > Privacy & Security > Accessibility
- Rebuild: re-run `./install.sh`, or `make -C ~/.local/share/bolt install`

### Rofi Not Responding
- Check keybinding conflicts: `xev` or `wev`
- Verify D-Bus: `echo $DBUS_SESSION_BUS_ADDRESS`
- Test command: `rofi -show drun`

### Performance Issues
- Limit search scope
- Disable unused plugins
- Clear cache/history
- Reduce animation duration