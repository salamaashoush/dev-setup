# Application Launcher Shortcuts

## Raycast (macOS)

### Core Navigation
- `Cmd+Space` → Open Raycast
- `Esc` → Close/Go back
- `Tab` → Autocomplete
- `Enter` → Execute
- `Cmd+Enter` → Execute and close
- `Cmd+K` → Clear search
- `Cmd+,` → Open preferences

### Search Modifiers
- `>` → Search commands only
- `@` → Search for people/contacts
- `#` → Search snippets
- `!` → Search scripts
- `?` → Search help

### Window Management (Built-in)
- `Cmd+Opt+Space` → Window management mode
- Then type:
  - `left` → Left half
  - `right` → Right half
  - `max` → Maximize
  - `center` → Center window
  - `full` → Fullscreen

### Clipboard History
- `Cmd+Opt+V` → Open clipboard history
- `↑↓` → Navigate items
- `Enter` → Paste
- `Cmd+C` → Copy again
- `Cmd+Delete` → Remove item
- `Space` → Preview
- `Cmd+F` → Search in history

### Quick Actions
- `Cmd+Space` then...
  - `cal` → Calendar
  - `rem` → Reminders
  - `emoji` → Emoji picker (or `Cmd+Opt+E`)
  - `color` → Color picker
  - `kill` → Kill process
  - `empty` → Empty trash
  - `lock` → Lock screen
  - `sleep` → Sleep computer

### File Search
- `Cmd+Space` → `f <query>` → Search files
- `Cmd+Space` → `o <app>` → Open recent files in app
- `Cmd+O` → Quick file browser (when in Raycast)

### Developer Commands
- `>github` → GitHub commands
- `>brew` → Homebrew commands
- `>ip` → Show IP addresses
- `>dns` → DNS lookup
- `>port` → Kill port
- `>encode` → Base64 encode/decode
- `>uuid` → Generate UUID
- `>lorem` → Lorem ipsum

### Custom Scripts
- `!script-name` → Run custom script
- `Cmd+Shift+C` → Create new script
- `Cmd+Option+R` → Reload scripts

### System Commands
- Type calculations directly: `2+2`, `sqrt(16)`
- `define <word>` → Dictionary
- `translate <text>` → Translation
- `weather` → Weather forecast
- `tz <city>` → Time zones

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
   - Raycast learns from usage
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

**Raycast**:
```bash
# Create alias commands
Preferences → Extensions → Search for "Alias"
```

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
   - Raycast: Browser bookmarks extension
   - Rofi: Firefox/Chrome bookmark scripts

2. **Password Managers**:
   - Raycast: 1Password extension
   - Rofi: `rofi-pass` for pass

3. **Project Switching**:
   - Create scripts for common projects
   - Include git status in preview
   - Auto-open in preferred editor

## Troubleshooting

### Raycast Not Opening
- Check: System Preferences → Security → Accessibility
- Reset: `defaults delete com.raycast.macos`
- Reinstall: `brew reinstall --cask raycast`

### Rofi Not Responding
- Check keybinding conflicts: `xev` or `wev`
- Verify D-Bus: `echo $DBUS_SESSION_BUS_ADDRESS`
- Test command: `rofi -show drun`

### Performance Issues
- Limit search scope
- Disable unused plugins
- Clear cache/history
- Reduce animation duration