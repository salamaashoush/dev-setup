# Development Tools Documentation

Runtimes, build tools, and most developer CLIs come from mise (`configs/mise/config.toml`), so macOS and Linux run the same versions. `mise up` upgrades them.

## Programming Languages

### Node.js
**Description**: JavaScript runtime built on Chrome's V8 engine  
**Version Management**: mise (`node = "lts"`)  
**Package Managers**: npm, pnpm, yarn, bun

**Tools Installed** (mise):
- **pnpm**: Fast, disk space efficient package manager
- **yarn**: Alternative package manager with workspaces
- **bun**: All-in-one JavaScript runtime and package manager

### Python
**Description**: High-level programming language  
**Version Management**: mise (`python = "latest"`, prebuilt python-build-standalone interpreters)  
**Packages and venvs**: uv (mise)

**Helpers** (`aliases.sh`): `py` (python3), `pyp` (`uv pip`), `pyvenv` (`uv venv`), `pyactivate`. Python CLI tools install through uv with `mise use -g pipx:<tool>`. Zed formats Python with its built-in ruff language server.

### Rust
**Description**: Systems programming language  
**Installation**: mise (`rust`, which drives rustup)

**Tools Installed** (mise):
- **cargo-binstall**: Binary installation for faster setup
- **sccache**: Shared compilation cache
- **cargo-watch**: Auto-rebuild on file changes
- **cargo-edit**: Add/remove dependencies from CLI
- **cargo-outdated**: Check for outdated dependencies
- **cargo-audit**: Security vulnerability audit
- **cargo-expand**: Show macro expansion results
- **cargo-nextest**: Faster test runner with better output
- **bacon**: Background code checker
- **wasm-pack**: Build Rust-generated WebAssembly packages

**Targets & components**: `wasm32-unknown-unknown` (Leptos, Yew, wasm-pack, Bevy web
builds), plus `rust-analyzer`, `clippy`, `rustfmt`.

**Cargo subcommands come from mise's cargo backend**, which fetches prebuilt binaries
through cargo-binstall instead of compiling each one from source.

#### mold linker

On Linux, `mold` and `lld` are installed and cargo is configured to link with mold:

```toml
# ~/.cargo/config.toml
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=mold"]
```

Linking dominates incremental Rust rebuild time, so this is usually the single
largest win on a multi-core machine.

**The installer will not overwrite an existing `~/.cargo/config.toml`.** If one is
already present it prints the snippet and leaves the file alone — a global cargo
config affects every project on the machine, so clobbering it is not something to do
silently.

### C/C++
**Description**: Systems programming languages  
**Compilers**: Clang from the Xcode Command Line Tools (macOS); GCC and Clang (Arch)

**Tools Installed**:
- **cmake**: Cross-platform build system (mise)
- **ninja**: Small, fast build system (mise)
- **just**: Modern command runner, make alternative (mise)
- **mold**, **lld**: Fast linkers (Arch)
- **gdb**, **lldb**: Debuggers (Arch, with the game development tools)

## Code Editors

### Zed
**Description**: High-performance code editor built in Rust  
**Command**: `zed` (Arch ships the CLI as `zeditor`; `install.sh` links `~/.local/bin/zed` to it)  
**Config**: `configs/zed/settings.json`, `configs/zed/keymap.json`

**Setup**:
- Tokyo Night Storm theme and Catppuccin Macchiato icons, from extensions Zed installs on first launch
- VS Code base keymap plus the bindings in `keymap.json` ([Editor Shortcuts](../shortcuts/editors.md))
- Edit predictions from Zed's own provider
- Format on save; Python through Zed's built-in ruff language server
- direnv loaded through the shell hook

**Why Zed?**
- GPU-accelerated rendering
- Instant startup
- Native performance
- Real-time collaboration
- Minimal resource usage

### Neovim
**Description**: Hyperextensible Vim-based editor  
**Command**: `nvim` (mise)  
**Config**: `~/.config/nvim/` (LazyVim starter, extras from `configs/lazyvim.json`)

**Why Neovim?**
- Terminal-based (works over SSH)
- Extensive plugin ecosystem
- LSP support
- Claude Code in the editor through LazyVim's `ai.claudecode` extra

## Version Control

### Git
**Description**: Distributed version control system  
**Essential**: Yes  
**Config**: `configs/gitconfig`

### Git Enhancement Tools

**git-delta**
- **Description**: Syntax-highlighting pager for git
- **Usage**: Automatic (configured in gitconfig)
- **Features**: Side-by-side diffs, line numbers, syntax highlighting, file links that open in Zed (`zed://file`)

**lazygit**
- **Description**: Terminal UI for git commands
- **Command**: `lg` (aliased)
- **Features**: Interactive staging, commit graph, merge conflict resolution

### GitHub CLI
**Command**: `gh`  
**Usage**:
```bash
gh repo clone owner/repo
gh pr create
gh issue list
gh pr review
```

## Database Tools

No database server is installed. `db-start` (from `aliases.sh`) runs one in Docker:

```bash
db-start postgres      # PostgreSQL 16 on 5432
db-start redis         # Redis on 6379
db-start mysql         # MySQL 8 on 3306
db-shell postgres      # psql, redis-cli, or mysql inside the container
db-stop postgres       # stop and remove it
```

## Containers

### Docker
**Description**: Container platform  
**macOS**: Docker CLI with the compose and buildx plugins, running on Colima ([Colima Optimizations](./colima-optimizations.md))  
**Linux**: Docker Engine with compose and buildx  
**TUI**: lazydocker (mise)

## API Development

### HTTP Clients
- **xh**: Command-line HTTP client with httpie's request syntax, in Rust
- **insomnia**: GUI API client

## Development Utilities

### Build Tools
- **just**: Modern command runner
- **cmake**: Cross-platform build generator
- **ninja**: Fast build system

### Performance Analysis
- **hyperfine**: Command-line benchmarking

### Code Quality
- **tokei**: Count lines of code
- **sccache**: Shared compilation cache

### Documentation
- **tldr**: Simplified man pages (the tlrc client)

## Language Servers (LSP)

- **rust-analyzer**: Installed with Rust by mise
- **Zed** downloads the language servers it needs on first use
- **LazyVim** installs servers for its enabled language extras through Mason

## Global Tools

Global tools come from mise rather than `npm -g`, `pip install`, or `cargo install` (Python CLIs: `mise use -g pipx:<tool>`, installed through uv). `mise use -g <tool>` writes to `~/.config/mise/config.toml`, separate from the managed `conf.d/dev-setup.toml`, so it survives a re-run of `install.sh`.

## Development Workflow Integration

### Pre-commit Hooks
- Automated code quality checks
- Format on commit
- Lint before push

### CI/CD Tools
- **GitHub Actions**: Via gh CLI

## Best Practices

1. **Use version managers**: mise for runtimes and CLI tools
2. **Isolate dependencies**: project virtual environments, per-project `mise.toml`
3. **Cache builds**: sccache for Rust
4. **Format consistently**: Configure formatters in each project
5. **Lint early**: Pre-commit hooks catch issues before commit