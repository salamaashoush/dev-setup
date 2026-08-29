# Development Tools Documentation

## Programming Languages

### Node.js
**Description**: JavaScript runtime built on Chrome's V8 engine  
**Version Management**: fnm (Fast Node Manager)  
**Package Managers**: npm, pnpm, yarn, bun

**Tools Installed**:
- **pnpm**: Fast, disk space efficient package manager
- **yarn**: Alternative package manager with workspaces
- **bun**: All-in-one JavaScript runtime and package manager
- **fnm**: Node version manager (`curl -fsSL https://fnm.vercel.app/install | bash`)

### Python
**Description**: High-level programming language  
**Version**: Python 3.12  
**Package Manager**: pip, pipx, uv, poetry

**Tools Installed**:
- **uv**: Ultra-fast Python package manager by Astral
- **pipx**: Install Python apps in isolated environments
- **poetry**: Dependency management and packaging
- **ruff**: Fast Python linter and formatter (10-100x faster than existing tools)
- **black**: The uncompromising code formatter

**Why these tools?**
- uv: Rust-based, 10-100x faster than pip
- pipx: Prevents global package conflicts
- poetry: Better than pip for project dependencies
- ruff: Replaces flake8, pylint, isort, and more

### Rust
**Description**: Systems programming language  
**Installation**: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

**Tools Installed**:
- **cargo-binstall**: Binary installation for faster setup
- **sccache**: Shared compilation cache
- **cargo-watch**: Auto-rebuild on file changes
- **cargo-edit**: Add/remove dependencies from CLI
- **cargo-outdated**: Check for outdated dependencies
- **cargo-audit**: Security vulnerability audit
- **cargo-expand**: Show macro expansion results
- **cargo-nextest**: Faster test runner with better output
- **bacon**: Background code checker

**Targets & components**: `wasm32-unknown-unknown` (Leptos, Yew, wasm-pack, Bevy web
builds), plus `rust-analyzer`, `clippy`, `rustfmt`.

**Tools are installed with `cargo binstall`** where possible — it downloads prebuilt
binaries instead of compiling each one from source, falling back to `cargo install`.

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

### Go
**Description**: Statically typed, compiled language by Google  
**Tools Installed**:
- **gopls**: Official Go language server
- **delve**: Debugger for Go
- **goimports**: Updates imports and formats code
- **golangci-lint**: Fast linters runner
- **air**: Live reload for Go apps

### C/C++
**Description**: Systems programming languages  
**Compilers**: GCC, Clang/LLVM

**Tools Installed**:
- **cmake**: Cross-platform build system
- **ninja**: Small, fast build system
- **llvm**: Complete compiler infrastructure
- **ccache**: Compiler cache for faster rebuilds
- **clang-format**: Code formatter
- **clang-tidy**: Linter and static analyzer
- **gdb**: GNU debugger
- **valgrind**: Memory debugging (Linux)
- **just**: Modern command runner (make alternative)

## Code Editors

### VS Code
**Description**: Microsoft's extensible code editor  
**Command**: `code`  
**Extensions**: Managed separately (see configs/vscode/)

**Key Features**:
- IntelliSense code completion
- Integrated debugging
- Git integration
- Extension ecosystem
- Remote development

### Zed
**Description**: High-performance, multiplayer code editor  
**Built in**: Rust for maximum performance  
**Command**: `zed`

**Why Zed?**
- GPU-accelerated rendering
- Instant startup
- Native performance
- Real-time collaboration
- Minimal resource usage

### Cursor
**Description**: AI-powered code editor (VS Code fork)  
**Command**: `cursor`

**AI Features**:
- Code generation
- Natural language edits
- Context-aware suggestions
- Chat interface

### Neovim
**Description**: Hyperextensible Vim-based editor  
**Command**: `nvim`  
**Config**: `~/.config/nvim/`

**Why Neovim?**
- Terminal-based (works over SSH)
- Extensive plugin ecosystem
- LSP support
- Lua configuration

## Version Control

### Git
**Description**: Distributed version control system  
**Essential**: Yes  
**Config**: `configs/gitconfig`

### Git Enhancement Tools

**git-delta**
- **Description**: Syntax-highlighting pager for git
- **Usage**: Automatic (configured in gitconfig)
- **Features**: Side-by-side diffs, line numbers, syntax highlighting

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

### PostgreSQL
**Version**: 17  
**Client**: psql  
**macOS**: Links as default version

### Redis
**Description**: In-memory data structure store  
**Usage**: Cache, message broker, queues

### SQLite
**Description**: Embedded SQL database  
**Usage**: Local development, testing

### DBeaver Community
**Description**: Universal database GUI  
**Supports**: PostgreSQL, MySQL, SQLite, MongoDB, and more

## Container & Orchestration

### Docker
**Description**: Container platform  
**GUI**: Docker Desktop

### macOS Specific
- **Colima**: Lightweight container runtime
- **OrbStack**: Fast Docker & Linux VMs

### Kubernetes Tools
- **kubectl**: Kubernetes CLI
- **helm**: Package manager for Kubernetes
- **k9s**: Terminal UI for Kubernetes

## API Development

### HTTP Clients
- **httpie**: User-friendly command-line HTTP client
- **xh**: Faster httpie alternative in Rust
- **insomnia**: GUI API client

### gRPC Tools
- **grpcurl**: Command-line gRPC client
- **grpcui**: Web UI for gRPC

## Development Utilities

### Build Tools
- **just**: Modern command runner
- **cmake**: Cross-platform build generator
- **ninja**: Fast build system

### Performance Analysis
- **hyperfine**: Command-line benchmarking
- **oha**: HTTP load testing
- **flamegraph**: Stack trace visualizer
- **py-spy**: Python profiler

### Code Quality
- **tokei**: Count lines of code
- **sccache**: Shared compilation cache

### Documentation
- **tldr**: Simplified man pages
- **dash** (macOS): API documentation browser
- **zeal** (Linux): Offline documentation browser

## Language Servers (LSP)

Installed automatically:
- **gopls**: Go
- **rust-analyzer**: Rust
- **pylsp**: Python
- **typescript-language-server**: TypeScript/JavaScript
- **clangd**: C/C++

## Package Registries & Tools

### Node.js Global Packages
```bash
npm install -g @anthropic-ai/claude-code  # Claude AI assistant
npm install -g typescript                 # TypeScript compiler
npm install -g prettier                   # Code formatter
npm install -g eslint                     # JavaScript linter
```

### Python Global Tools (via pipx)
```bash
pipx install black          # Code formatter
pipx install mypy          # Static type checker
pipx install pre-commit    # Git hook framework
```

### Rust Global Tools (via cargo)
```bash
cargo install --locked bacon      # Background compiler
cargo install --locked tokei      # Code statistics
cargo install --locked bat        # Better cat
```

## Development Workflow Integration

### Pre-commit Hooks
- Automated code quality checks
- Format on commit
- Lint before push

### CI/CD Tools
- **GitHub Actions**: Via gh CLI
- **ansible**: Automation and configuration
- **terraform**: Infrastructure as code

### Cloud CLIs
- **aws-cli**: AWS services
- **azure-cli**: Azure services
- **gcloud**: Google Cloud Platform

## Best Practices

1. **Use version managers**: fnm for Node, rustup for Rust
2. **Isolate dependencies**: pipx for Python tools, project virtual environments
3. **Cache builds**: ccache for C/C++, sccache for Rust
4. **Format consistently**: Configure formatters in each project
5. **Lint early**: Pre-commit hooks catch issues before commit