# Editor Keyboard Shortcuts

Zed is the GUI editor and Neovim with LazyVim the terminal editor.

## Zed Editor

Zed uses its VS Code base keymap (`"base_keymap": "VSCode"`) with no custom
bindings, so VS Code habits carry over. `Mod` below is `Cmd` on macOS and
`Ctrl` on Linux. On Arch the Zed CLI is `zeditor`, and `install.sh` links
`~/.local/bin/zed` to it, so `zed .` works on both platforms.

- `Mod+P` → File finder; `Mod+Shift+P` → Command palette
- `Mod+Shift+F` → Project search; `Mod+Shift+O` → Symbols in file
- `Mod+B` → Toggle project panel; `Mod+J` → Toggle bottom dock
- ``Ctrl+` `` → Terminal
- `Mod+D` → Select next occurrence; `Mod+Shift+L` → Select all occurrences
- `Alt+Up/Down` → Move line; `Shift+Alt+Up/Down` → Duplicate line
- `Mod+/` → Toggle comment
- `F12` → Go to definition; `Shift+F12` → References; `F2` → Rename
- `Mod+.` → Code actions
- `Mod+,` → Settings; `Mod+K Mod+S` → Keymap

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
| Quick Fix | `Cmd+.` | `<leader>ca` |

## Tips for Efficiency

1. **Learn incrementally**: Master 5 shortcuts per week
2. **Use command palette**: When you forget a shortcut
3. **Customize conflicts**: Remap shortcuts that conflict with OS
4. **Practice pair**: Navigation + editing shortcuts together
5. **Sticky note method**: Keep current learning shortcuts visible

## Customization Locations

- **Zed**: `~/.config/zed/keymap.json`, yours alone; the repo ships none
- **Neovim**: `~/.config/nvim/lua/config/keymaps.lua`; LazyVim extras in `~/.config/nvim/lazyvim.json` (from `configs/lazyvim.json`)
