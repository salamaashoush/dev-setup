# Development Workflow Shortcuts

## Quick Start Workflows

### New Project Setup
```bash
# Create project with template
mkdir my-project && cd my-project
git init

# Node.js
pnpm init
pnpm add -D typescript @types/node tsx vitest
# Create from template
cp -r ~/.config/project-templates/node/* .

# Python
uv init                    # pyproject.toml, .python-version
uv add requests            # adds the dependency and syncs .venv
uv run main.py             # runs inside the project's .venv

# Rust
cargo init
# Create from template
cp -r ~/.config/project-templates/rust/* .

# Go
go mod init github.com/user/project
# Create from template
cp -r ~/.config/project-templates/go/* .
```

### Common Development Tasks

#### Git Workflow
```bash
# Quick status check
gs                      # git status (alias)

# Interactive staging
lg                      # lazygit (full UI)
ga -p                   # git add --patch

# Commit with conventional format
gc -m "feat: add new feature"
gc -m "fix: resolve issue #123"
gc -m "docs: update README"

# Quick amend
gca                     # git commit --amend
gcane                   # amend without editing message

# Branch operations
gco -b feature/new     # checkout new branch
gco main              # checkout main
gm main               # merge main
grb main              # rebase on main
```

#### File Operations
```bash
# Quick navigation
z project              # jump to project directory
zi project             # interactive selection

# Find files
fd README              # find files named README
fd -e py test_         # find Python test files
fd -H .env            # find hidden files

# Search content  
rg "TODO"             # search for TODO
rg -t py "import"     # search Python files
rg -A 3 -B 3 "error"  # with context
```

#### Running Tests
```bash
# Language specific
pnpm test             # Node.js
pytest                # Python
cargo test            # Rust  
go test ./...         # Go

# Watch mode
pnpm test:watch       # Node.js
pytest-watch          # Python
cargo watch -x test   # Rust
air                   # Go with air
```

## IDE Integration Workflows

### Zed
```bash
# Open project (on Arch, zed is a link to zeditor)
zed .                  # open current directory
zed ~/Workspace/app    # open specific project

# Quick actions via command line
zed file.ts:10:5           # open at line/column
zed --diff file1 file2     # compare files
zed --add folder           # add folder to the open workspace
```

**Common sequences:**
1. `Cmd+P` → type filename → `Enter` (open file)
2. `Cmd+Shift+P` → "format" → `Enter` (format document)
3. `Ctrl+Shift+O` → symbol name (go to symbol)
4. `Cmd+P` → `file:line` (open at line)

### Terminal + Editor Combo

**Quick edit workflow:**
```bash
# Find and edit
fd -e py | fzf | xargs zed

# Grep and edit
rg -l "pattern" | fzf | xargs zed

# Edit modified files
git status --short | awk '{print $2}' | fzf -m | xargs zed
```

**Terminal beside editor:**
- macOS: `Cmd+Opt+T` for terminal, `Cmd+Tab` to switch
- Linux: `Ctrl+Alt+T` for terminal, `Alt+Tab` to switch
- Or use editor's integrated terminal

## Debugging Workflows

### Print Debugging
```python
# Python
import pdb; pdb.set_trace()  # Breakpoint
print(f"DEBUG: {variable=}")  # Python 3.8+

# JavaScript/TypeScript  
console.log('DEBUG:', variable)
debugger;  // Breakpoint

# Rust
dbg!(&variable);
println!("DEBUG: {:?}", variable);

# Go
fmt.Printf("DEBUG: %+v\n", variable)
```

### Interactive Debugging

**Neovim (LazyVim `dap.core` extra):**
1. `<leader>dc` → Start/continue debugging
2. `<leader>db` → Toggle breakpoint
3. `<leader>dO` → Step over
4. `<leader>di` → Step into

**Terminal debuggers:**
```bash
# Python
python -m pdb script.py
ipdb3 script.py         # better debugger

# Rust
rust-gdb target/debug/binary
rust-lldb target/debug/binary

# Go  
dlv debug
dlv test
```

## Build & Deploy Workflows

### Local Development
```bash
# Start dev servers
pnpm dev              # Node.js
python -m flask run   # Flask
cargo watch -x run    # Rust
air                   # Go

# Build for production
pnpm build            # Node.js
python -m build       # Python
cargo build --release # Rust
go build -o app      # Go
```

### Container Workflows
```bash
# Quick build and run
docker build -t app . && docker run -it app

# Development with hot reload
docker-compose up     # start services
docker-compose logs -f app  # tail logs
docker-compose exec app sh  # shell into container

# Quick cleanup
docker-compose down -v  # stop and remove volumes
docker system prune -a  # cleanup everything
```

## Code Quality Workflows

### Formatting
```bash
# Format on save (configure in editor)
# Or format manually:
prettier --write .    # JavaScript/TypeScript
black .              # Python
cargo fmt            # Rust
gofmt -w .          # Go
```

### Linting
```bash
# Run linters
eslint .             # JavaScript/TypeScript
ruff check .         # Python (fast)
cargo clippy         # Rust
golangci-lint run    # Go

# Auto-fix
eslint --fix .
ruff check --fix .
```

### Pre-commit Hooks
```bash
# Install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files

# Skip hooks (emergency)
git commit --no-verify
```

## Productivity Boosters

### Quick Commands
```bash
# HTTP requests
xh api.example.com/users        # GET
xh POST api.example.com/users name=salama  # JSON body

# JSON processing
curl api.example.com | jq '.data[]'
echo '{"key": "value"}' | jq .

# Quick server
python -m http.server 8000      # Python
miniserve .                     # Rust (better)

# Monitor commands
watch -n 1 'command'            # run every second
command | pv                    # progress view
```

### Aliases for Common Patterns
```bash
# Add to ~/.zshrc
alias gls='git log --oneline --graph --decorate'
alias gwip='git add -A && git commit -m "WIP"'
alias gunwip='git reset HEAD~1 --mixed'
alias pns='pnpm start'
alias pnb='pnpm build'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
```

### Project Switching
```bash
# With direnv
cd ~/Workspace/app1   # auto-loads .envrc
cd ~/Workspace/app2   # switches environment

# Quick project opener (add to ~/.zshrc)
proj() {
    cd ~/Workspace/$1 && zed .
}
# Usage: proj myapp
```

## Terminal Multiplexing Workflows

### herdr Sessions
```bash
# Project session (attach, or create if missing)
hrs myproject          # herdr --session myproject

# List and stop sessions
hrl                    # herdr session list
hrk myproject          # herdr session stop myproject

# Quick actions in herdr (prefix Ctrl+Space)
Alt+Enter → Split horizontally
Alt+Shift+Enter → Split vertically
Ctrl+Alt+Arrow → Focus pane
Ctrl+Space, c → New tab
```

### Kitty Windows
```bash
# Launch with session
kitty --session ~/.config/kitty/dev-session.conf

# Quick splits
Cmd+Enter → New window
Cmd+Shift+D → Split horizontal
Ctrl+Cmd+D → Split vertical
```

## Quick Reference Card

```
File Nav:        Search:          Git:            Run:
z <dir>         rg pattern       lg              pnpm dev
fd name         rg -t py         gs              cargo run
eza -la         fd -e js         gc -m ""        go run .
                                gp              python app.py

Edit:           Debug:           Quality:        Tools:
zed .           <leader>dc       black .         docker-compose up
nvim file       dbg!()          cargo fmt       lazydocker
Cmd+P (open)    console.log     eslint .        xh GET url
```

## Workflow Optimization Tips

1. **Use fuzzy finders**: Integrate fzf with everything
2. **Create project templates**: Standardize setup
3. **Keyboard over mouse**: Learn editor shortcuts
4. **Automate repetitive tasks**: Shell functions/aliases
5. **Session management**: herdr/Kitty for project contexts