# Editor Keyboard Shortcuts

## VS Code

### Essential Navigation
- `Cmd+P` (macOS) / `Ctrl+P` (Linux) → Quick file open
- `Cmd+Shift+P` (macOS) / `Ctrl+Shift+P` (Linux) → Command palette
- `Cmd+B` (macOS) / `Ctrl+B` (Linux) → Toggle sidebar
- `Cmd+J` (macOS) / `Ctrl+J` (Linux) → Toggle terminal
- `Cmd+\` (macOS) / `Ctrl+\` (Linux) → Split editor
- `Cmd+1/2/3` (macOS) / `Ctrl+1/2/3` (Linux) → Focus editor group

### File Operations
- `Cmd+N` (macOS) / `Ctrl+N` (Linux) → New file
- `Cmd+S` (macOS) / `Ctrl+S` (Linux) → Save
- `Cmd+Shift+S` (macOS) / `Ctrl+Shift+S` (Linux) → Save as
- `Cmd+W` (macOS) / `Ctrl+W` (Linux) → Close editor
- `Cmd+Shift+T` (macOS) / `Ctrl+Shift+T` (Linux) → Reopen closed editor

### Editing
- `Cmd+X` (macOS) / `Ctrl+X` (Linux) → Cut line (empty selection)
- `Cmd+C` (macOS) / `Ctrl+C` (Linux) → Copy line (empty selection)
- `Alt+Up/Down` → Move line up/down
- `Shift+Alt+Up/Down` → Copy line up/down
- `Cmd+Enter` (macOS) / `Ctrl+Enter` (Linux) → Insert line below
- `Cmd+Shift+Enter` (macOS) / `Ctrl+Shift+Enter` (Linux) → Insert line above
- `Cmd+Shift+K` (macOS) / `Ctrl+Shift+K` (Linux) → Delete line
- `Cmd+/` (macOS) / `Ctrl+/` (Linux) → Toggle line comment
- `Shift+Alt+A` → Toggle block comment

### Multi-cursor & Selection
- `Cmd+D` (macOS) / `Ctrl+D` (Linux) → Add selection to next find match
- `Cmd+K Cmd+D` (macOS) / `Ctrl+K Ctrl+D` (Linux) → Skip selection
- `Cmd+U` (macOS) / `Ctrl+U` (Linux) → Undo cursor operation
- `Alt+Click` → Insert cursor
- `Cmd+Alt+Up/Down` (macOS) / `Ctrl+Alt+Up/Down` (Linux) → Insert cursor above/below
- `Cmd+Shift+L` (macOS) / `Ctrl+Shift+L` (Linux) → Select all occurrences
- `Shift+Alt+Drag` → Column (box) selection

### Search & Replace
- `Cmd+F` (macOS) / `Ctrl+F` (Linux) → Find
- `Cmd+H` (macOS) / `Ctrl+H` (Linux) → Replace
- `Cmd+Shift+F` (macOS) / `Ctrl+Shift+F` (Linux) → Find in files
- `Cmd+Shift+H` (macOS) / `Ctrl+Shift+H` (Linux) → Replace in files
- `F3` / `Shift+F3` → Find next/previous
- `Cmd+G` (macOS) / `Ctrl+G` (Linux) → Go to line

### Code Navigation
- `F12` → Go to definition
- `Alt+F12` → Peek definition
- `Shift+F12` → Show references
- `Cmd+Shift+O` (macOS) / `Ctrl+Shift+O` (Linux) → Go to symbol
- `Cmd+T` (macOS) / `Ctrl+T` (Linux) → Go to symbol in workspace
- `Ctrl+-` / `Ctrl+Shift+-` → Navigate back/forward
- `Cmd+Shift+[/]` (macOS) / `Ctrl+Shift+[/]` (Linux) → Fold/unfold region

### IntelliSense
- `Ctrl+Space` → Trigger suggestions
- `Ctrl+Shift+Space` → Trigger parameter hints
- `Cmd+.` (macOS) / `Ctrl+.` (Linux) → Quick fix
- `F2` → Rename symbol
- `Shift+Alt+F` → Format document
- `Cmd+K Cmd+F` (macOS) / `Ctrl+K Ctrl+F` (Linux) → Format selection

### Debugging
- `F5` → Start/continue
- `Shift+F5` → Stop
- `F10` → Step over
- `F11` → Step into
- `Shift+F11` → Step out
- `F9` → Toggle breakpoint

### Terminal
- `Ctrl+`` → Show integrated terminal
- `Ctrl+Shift+`` → Create new terminal
- `Cmd+\` (macOS) / `Ctrl+Shift+5` (Linux) → Split terminal
- `Alt+Cmd+0` (macOS) / `Alt+0` (Linux) → Toggle terminal focus

## Zed Editor

### File Navigation
- `Cmd+P` → File finder
- `Cmd+Shift+P` → Command palette
- `Cmd+B` → Toggle file tree
- `Cmd+Shift+E` → Focus file tree
- `Cmd+Shift+F` → Project search

### Editing
- `Cmd+D` → Add selection to next occurrence
- `Cmd+Shift+L` → Select all occurrences
- `Cmd+/` → Toggle comment
- `Alt+Up/Down` → Move line
- `Cmd+Shift+D` → Duplicate line
- `Cmd+X` → Cut line (empty selection)

### Multi-cursor
- `Alt+Click` → Add cursor
- `Alt+Shift+Up/Down` → Add cursor above/below
- `Cmd+Alt+Up/Down` → Add cursor to line above/below

### Code Intelligence
- `F12` → Go to definition
- `Shift+F12` → Find references
- `F2` → Rename
- `Cmd+.` → Code actions

### Pane Management
- `Cmd+K Arrow` → Move focus
- `Cmd+K Cmd+Arrow` → Move pane
- `Cmd+\` → Split pane
- `Cmd+W` → Close pane

## Cursor (AI Editor)

### AI Features
- `Cmd+K` → AI command bar
- `Cmd+L` → Open chat
- `Cmd+Shift+L` → Chat with codebase
- `Tab` → Accept suggestion
- `Esc` → Dismiss suggestion

### Cursor-specific
- `Cmd+Shift+K` → Generate code
- `Cmd+Shift+I` → Explain code
- `Cmd+Shift+E` → Edit with AI
- `Alt+Enter` → Apply AI edit

(Other shortcuts same as VS Code)

## Neovim

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

### Common Plugins Shortcuts
- `<leader>ff` → Find files (Telescope)
- `<leader>fg` → Live grep (Telescope)
- `<leader>fb` → Browse buffers
- `<leader>e` → File explorer (NvimTree)
- `gd` → Go to definition (LSP)
- `gr` → Show references (LSP)
- `K` → Show hover docs (LSP)

## Helix Editor

### Modes
- `Esc` → Normal mode
- `i` → Insert mode
- `a` → Append mode
- `o` → Open line below
- `O` → Open line above
- `v` → Select mode
- `x` → Extend selection mode
- `g` → Goto mode prefix

### Navigation (Normal Mode)
- `h/j/k/l` → Left/down/up/right
- `w/b` → Next/previous word
- `e` → End of word
- `0` → Start of line
- `$` → End of line
- `gg` → First line
- `G` → Last line
- `Ctrl+u/d` → Half page up/down
- `Ctrl+f/b` → Full page down/up
- `%` → Matching bracket

### Editing (Normal Mode)
- `d` → Delete selection
- `c` → Change selection
- `y` → Yank (copy)
- `p/P` → Paste after/before
- `u` → Undo
- `U` → Redo
- `r` → Replace character
- `~` → Toggle case
- `.` → Repeat last edit
- `>/>` → Indent line
- `</<` → Unindent line

### Selection & Multiple Cursors
- `x` → Extend selection
- `X` → Shrink selection
- `s` → Select regex in selection
- `S` → Split selection on regex
- `Alt+s` → Split selection on newlines
- `&` → Align selections
- `Alt+.` → Repeat last motion
- `C` → Copy selection to next line
- `Alt+C` → Copy selection to previous line
- `,` → Keep only primary selection
- `Alt+,` → Remove primary selection

### Search & Replace
- `/` → Search forward
- `?` → Search backward
- `n/N` → Next/previous match
- `*` → Search word under cursor
- `R` → Replace selection with yanked text
- `:s/old/new/` → Substitute in selection

### Code Navigation
- `gd` → Go to definition
- `gy` → Go to type definition
- `gr` → Go to references
- `gi` → Go to implementation
- `ga` → Go to last accessed file
- `gn` → Go to next diagnostic
- `gp` → Go to previous diagnostic
- `]d` → Go to next diagnostic
- `[d` → Go to previous diagnostic
- `Space+s` → Symbol picker
- `Space+S` → Workspace symbol picker

### File Operations
- `Space+f` → File picker
- `Space+b` → Buffer picker
- `Space+j` → Jumplist picker
- `:w` → Save file
- `:wq` → Save and quit
- `:q` → Quit
- `:q!` → Force quit
- `:bc` → Close buffer
- `:bn/:bp` → Next/previous buffer

### LSP Features
- `K` → Show hover documentation
- `Space+k` → Show signature help
- `Space+r` → Rename symbol
- `Space+a` → Code actions
- `Space+d` → Show diagnostics picker
- `Space+D` → Show workspace diagnostics
- `=` → Format selection
- `Space+=` → Format entire file

### Window Management
- `Ctrl+w s` → Horizontal split
- `Ctrl+w v` → Vertical split
- `Ctrl+w h/j/k/l` → Navigate windows
- `Ctrl+w H/J/K/L` → Swap windows
- `Ctrl+w q` → Close window
- `Ctrl+w o` → Close other windows

### Helix-Specific Features
- `mi` → Match inside (select inside delimiters)
- `ma` → Match around (select around delimiters)
- `mm` → Match to matching bracket
- `Space+?` → Command palette
- `Ctrl+c` → Toggle comments
- `Alt+(/)` → Rotate selection contents
- `Q` → Record macro
- `q` → Play macro
- `Space+'` → Open last picker

### Configuration
- Config location: `~/.config/helix/config.toml`
- Language config: `~/.config/helix/languages.toml`
- Runtime directory: `~/.config/helix/runtime/`
- Themes directory: `~/.config/helix/themes/`

### Tips for Helix
1. **Selection-first editing**: Unlike Vim, Helix uses selection → action
2. **Multiple cursors by default**: Many operations create multiple cursors
3. **Tree-sitter powered**: Syntax-aware selections and navigation
4. **Built-in LSP**: No plugins needed for language features
5. **Space as leader**: Most commands start with Space
6. **Persistent selections**: Selections remain after operations

## Common IDE Features Across Editors

### Quick Actions
| Action | VS Code | Zed | Cursor | Neovim | Helix |
|--------|---------|-----|--------|---------|--------|
| Command Palette | `Cmd+Shift+P` | `Cmd+Shift+P` | `Cmd+Shift+P` | `:` | `Space+?` |
| File Finder | `Cmd+P` | `Cmd+P` | `Cmd+P` | `<leader>ff` | `Space+f` |
| Go to Definition | `F12` | `F12` | `F12` | `gd` | `gd` |
| Find References | `Shift+F12` | `Shift+F12` | `Shift+F12` | `gr` | `gr` |
| Rename | `F2` | `F2` | `F2` | `<leader>rn` | `Space+r` |
| Quick Fix | `Cmd+.` | `Cmd+.` | `Cmd+.` | `<leader>ca` | `Space+a` |

### Multi-cursor Operations
| Action | VS Code | Zed | Cursor |
|--------|---------|-----|--------|
| Add Cursor | `Alt+Click` | `Alt+Click` | `Alt+Click` |
| Add Next Occurrence | `Cmd+D` | `Cmd+D` | `Cmd+D` |
| Add All Occurrences | `Cmd+Shift+L` | `Cmd+Shift+L` | `Cmd+Shift+L` |
| Column Selection | `Shift+Alt+Drag` | `Shift+Alt+Drag` | `Shift+Alt+Drag` |

## Tips for Efficiency

1. **Learn incrementally**: Master 5 shortcuts per week
2. **Use command palette**: When you forget a shortcut
3. **Customize conflicts**: Remap shortcuts that conflict with OS
4. **Practice pair**: Navigation + editing shortcuts together
5. **Sticky note method**: Keep current learning shortcuts visible

## Customization Locations

- **VS Code**: `Preferences → Keyboard Shortcuts` or `keybindings.json`
- **Zed**: `~/.config/zed/keymap.json`
- **Cursor**: Same as VS Code
- **Neovim**: `~/.config/nvim/lua/keymaps.lua` (typical)