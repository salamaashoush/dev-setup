# Editor Keyboard Shortcuts

Zed is the GUI editor and Neovim with LazyVim the terminal editor.

## Zed Editor

Zed runs on its VS Code base keymap (`"base_keymap": "VSCode"`), with the additions in `configs/zed/keymap.json`. Base keymap shortcuts use `Cmd` on macOS and `Ctrl` on Linux; the `keymap.json` additions use `Ctrl` on both. On Arch the Zed CLI is `zeditor`, and `install.sh` links `~/.local/bin/zed` to it, so `zed .` works on both platforms.

### File Navigation
- `Cmd+P` (macOS) / `Ctrl+P` (Linux) → File finder
- `Cmd+Shift+P` (macOS) / `Ctrl+Shift+P` (Linux) → Command palette
- `Cmd+Shift+F` (macOS) / `Ctrl+Shift+F` (Linux) → Project search
- `Ctrl+Shift+E` → Focus project panel
- `Ctrl+Shift+O` → Outline
- `Ctrl+Shift+R` → Project symbols

### Panels & Terminal
- `Ctrl+B` → Toggle left dock (project panel)
- `Ctrl+\` → Toggle right dock
- `Ctrl+J` → Toggle bottom dock
- ``Ctrl+` `` → Focus terminal
- ``Ctrl+Shift+` `` → New terminal
- `Ctrl+Shift+C` / `Ctrl+Shift+V` → Copy/paste in the terminal

### Editing
- `Ctrl+Shift+Up/Down` → Move line up/down
- `Alt+Shift+Up/Down` → Duplicate line up/down
- `Ctrl+Shift+K` → Delete line
- `Ctrl+Enter` / `Ctrl+Shift+Enter` → Insert line below/above
- `Ctrl+/` → Toggle line comment
- `Ctrl+Shift+A` → Toggle block comment
- `Ctrl+Shift+[` / `Ctrl+Shift+]` → Fold/unfold
- `Ctrl+K Ctrl+0` / `Ctrl+K Ctrl+J` → Fold/unfold all

### Multi-cursor
- `Alt+Click` → Add cursor
- `Ctrl+Alt+Up/Down` → Add cursor above/below
- `Ctrl+D` → Select next occurrence
- `Ctrl+Shift+L` → Select all occurrences
- `Ctrl+U` → Undo last selection

### Code Intelligence
- `F12` → Go to definition
- `Alt+F12` → Go to definition in a split
- `Ctrl+F12` → Go to implementation
- `Shift+F12` → Find references
- `F2` → Rename
- `Ctrl+.` → Code actions
- `Tab` → Accept edit prediction (Zed's own provider)

### Panes & Tabs
- `Ctrl+K Arrow` → Focus pane in that direction
- `Ctrl+K Ctrl+Arrow` → Split pane in that direction
- `Ctrl+Tab` / `Ctrl+Shift+Tab` → Next/previous tab
- `Alt+Left/Right` → Previous/next tab
- `Ctrl+W` → Close tab
- `Ctrl+Shift+N` / `Ctrl+Shift+W` → New/close window

### Settings
- `Ctrl+K Ctrl+S` → Open keymap
- `Ctrl+K Ctrl+T` → Theme selector
- Theme: Tokyo Night Storm from the `tokyo-night` extension, icons: Catppuccin Macchiato from `catppuccin-icons`. Zed installs both on first launch.
- Formatting runs on save: Prettier for web languages, the language server for Rust, Go and C++, and Zed's built-in ruff language server for Python.

## Neovim (LazyVim)

### Modes
- `Esc` → Normal mode
- `i` → Insert mode
- `v` → Visual mode
- `V` → Visual line mode
- `Ctrl+V` → Visual block mode
- `:` → Command mode

### Navigation (Normal Mode)
- `h/j/k/l` → Left/down/up/right
- `w/b` → Next/previous word
- `0/$` → Beginning/end of line
- `gg/G` → First/last line
- `Ctrl+U/D` → Half page up/down
- `Ctrl+F/B` → Full page down/up
- `%` → Matching bracket

### Editing (Normal Mode)
- `dd` → Delete line
- `yy` → Yank (copy) line
- `p/P` → Paste after/before
- `u` → Undo
- `Ctrl+R` → Redo
- `ciw` → Change inner word
- `ci"` → Change inside quotes
- `>>/<<` → Indent/dedent

### Search
- `/pattern` → Search forward
- `?pattern` → Search backward
- `n/N` → Next/previous match
- `*/#` → Search word under cursor
- `:s/old/new/g` → Replace in line
- `:%s/old/new/g` → Replace in file

### Windows & Tabs
- `:split` → Horizontal split
- `:vsplit` → Vertical split
- `Ctrl+W h/j/k/l` → Navigate windows
- `Ctrl+W =` → Equal size windows
- `:tabnew` → New tab
- `gt/gT` → Next/previous tab

### LazyVim Shortcuts
- `<leader>ff` → Find files
- `<leader>/` → Grep
- `<leader>fb` → Buffers
- `<leader>e` → File explorer
- `gd` → Go to definition (LSP)
- `gr` → Show references (LSP)
- `K` → Show hover docs (LSP)
- `<leader>cr` → Rename (LSP)
- `<leader>ca` → Code action (LSP)

### Claude Code (`ai.claudecode` extra)
- `<leader>ac` → Toggle Claude
- `<leader>af` → Focus Claude
- `<leader>ar` → Resume a Claude session
- `<leader>aC` → Continue the last Claude session
- `<leader>ab` → Add current buffer
- `<leader>as` → Send selection (visual mode)
- `<leader>aa` / `<leader>ad` → Accept/deny diff

## Common IDE Features Across Editors

### Quick Actions
| Action | Zed | Neovim |
|--------|-----|---------|
| Command Palette | `Cmd+Shift+P` | `:` |
| File Finder | `Cmd+P` | `<leader>ff` |
| Go to Definition | `F12` | `gd` |
| Find References | `Shift+F12` | `gr` |
| Rename | `F2` | `<leader>cr` |
| Quick Fix | `Ctrl+.` | `<leader>ca` |

## Tips for Efficiency

1. **Learn incrementally**: Master 5 shortcuts per week
2. **Use command palette**: When you forget a shortcut
3. **Customize conflicts**: Remap shortcuts that conflict with OS
4. **Practice pair**: Navigation + editing shortcuts together
5. **Sticky note method**: Keep current learning shortcuts visible

## Customization Locations

- **Zed**: `~/.config/zed/keymap.json` (from `configs/zed/keymap.json`)
- **Neovim**: `~/.config/nvim/lua/config/keymaps.lua`; LazyVim extras in `~/.config/nvim/lazyvim.json` (from `configs/lazyvim.json`)
