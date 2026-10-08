# dev-setup

One command turns a new Mac (or an Arch Linux box) into a web, Rust, C++ and
Python development machine: shell, terminal, editors, toolchains, containers and
apps, all themed Tokyo Night Storm.

## Install

On a new Mac, open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/salamaashoush/dev-setup/main/bootstrap.sh)"
```

`bootstrap.sh` runs under the bash 3.2 that macOS ships. It asks for your
password once, installs Homebrew (which brings the Xcode Command Line Tools and
git) and a current bash, clones this repository to `~/Workspace/dev-setup`, and
hands over to `install.sh`. Use `bash -c "$(curl ...)"` as shown, not
`curl ... | bash`: the installer asks questions, and a piped script has no
terminal to ask them on.

The one-liner needs the repository to be public. For a private copy, get the
repository onto the machine any other way and run:

```bash
cd ~/Workspace/dev-setup && ./install.sh
```

That works on a stock Mac too: `install.sh` notices the old bash and runs
`bootstrap.sh` first. On Arch Linux (including CachyOS and EndeavourOS) the same
command applies.

`install.sh` asks everything at the start: your Git name and email, an SSH key
passphrase, whether to install game development tools, whether to set up
agent-kit, and on Linux whether to install gaming packages. If agent-kit is on,
a GitHub sign-in opens in the browser a minute later. After that it runs unattended and ends with a summary
that lists any package that failed to install. Re-running it is safe and
updates everything in place.

## What you get

**Shell.** zsh with zinit, loading syntax highlighting, autosuggestions and
completions after the first prompt; Starship for the prompt; fzf, zoxide, eza,
bat, ripgrep, fd and yazi wired together; over a hundred aliases and functions
in `configs/aliases.sh` (run `cheat` for the list). Tool init scripts are cached,
so a new shell reaches its prompt in about 37 ms in an Arch container.

**Terminal.** Ghostty (Kitty as a fallback) with the CaskaydiaCove Nerd Font,
and [herdr](https://herdr.dev) as the multiplexer for terminals and Claude Code
sessions (prefix `Ctrl+Space`, tmux-style bindings).

**Editors.** Zed for the GUI and Neovim with LazyVim in the terminal. LazyVim
includes the Claude Code extra (`<leader>ac` toggles Claude).

**Toolchains.** Node.js LTS, Bun, pnpm, yarn, Python with uv (`pyp` is
`uv pip`, `pyvenv` is `uv venv`), Rust (with rust-analyzer, clippy,
rustfmt and the wasm32 target), cargo-watch, cargo-nextest, bacon and friends,
CMake, Ninja, just and sccache. C and C++ compilers come from the Xcode Command
Line Tools on macOS and `base-devel`/clang on Linux, where mold is also set up
as the Rust linker.

**AI.** Claude Code, plus the herdr integration that lets herdr resume Claude
sessions. No other agent is installed. With a GitHub sign-in (asked up front),
[agent-kit](https://github.com/salamaashoush/agent-kit) is cloned to
`~/Workspace/agent-kit` and installed: global instructions, hooks and skills,
with rtk and ferridriver (both from mise) wired in. An existing clone there is
used as it is.

**Containers.** Docker CLI with Compose and Buildx on Colima (macOS) or the
Docker daemon (Linux), lazydocker, and
[Dockside](https://github.com/salamaashoush/dockside) as the desktop UI.

**Git.** A tuned `~/.gitconfig` with delta as the pager, lazygit, gitui, gh, a
global gitignore and commit template, and an ed25519 SSH key.

**Launcher (macOS).** [Bolt](https://github.com/salamaashoush/bolt), built from
source as the last step (it needs macOS 15 and Swift 6.2 from the Command Line
Tools). Its first build creates a self-signed signing certificate, so macOS asks
once to trust it; choose Always Allow. Spotlight's `Cmd+Space` is turned off so
Bolt can take it (`Option+Space` works too). Grant it Accessibility for window
management. Linux uses Rofi.

**Apps (macOS).** Google Chrome, Rectangle, Stats, Slack, Discord, 1Password,
Insomnia, OBS and Steam. Linux gets the native equivalents plus KDE Plasma
tweaks, GPU drivers and optional gaming packages.

**Disk cleanup.** [sweeprs](https://github.com/salamaashoush/sweeprs), installed
by mise from its releases.

**Folders.** `~/Workspace` for projects.

**macOS defaults.** Faster key repeat and Dock animations, Finder path and
status bars with hidden files shown, screenshots in `~/Pictures/Screenshots`,
and Safari's developer menu. On Apple Silicon, Rosetta 2 is installed because
Colima uses it for x86_64 containers.

## How tools are installed

mise installs everything its registry carries, so both platforms run the same
versions. `configs/mise/config.toml` is copied to
`~/.config/mise/conf.d/dev-setup.toml`; mise merges that with your own
`~/.config/mise/config.toml`, so tools you add with `mise use -g` stay yours.

Homebrew and pacman keep what needs system integration or has no macOS arm64
build in mise: zsh, git, eza, btop, Docker and Colima, a handful of network
tools, GUI apps and fonts.

Upgrade everything with `topgrade`, or separately with `mise up` and
`brew upgrade`.

## Making it yours

`install.sh` overwrites the config files it ships each time it runs (it backs
up `~/.zshrc`, `~/.gitconfig` and the Kitty config first, to
`~/.dev-setup-backup/`). Keep personal changes where it never writes:

- `~/.zshrc.local` for shell settings, sourced last
- `~/.config/mise/config.toml` for extra tools (`mise use -g <tool>`)
- Neovim: an existing `~/.config/nvim` is left alone

## Repository layout

```
bootstrap.sh            fresh-machine entry point (bash 3.2 safe)
install.sh              the installer
configs/
  zshrc, aliases.sh     shell
  starship.toml         prompt
  ghostty.conf          terminal (kitty.conf as fallback)
  herdr/                multiplexer
  mise/                 tools mise installs
  zed/, lazyvim.json    editors
  gitconfig, ...        git
  colima/, docker/      containers
  yazi/, btop.conf, lazygit.yml, topgrade.toml, bat/, ...
  rofi/, kwin/, plasma-layout.js   Linux desktop
  scripts/              helpers installed to ~/.local/bin
  project-templates/    starters for Node, Rust and C++ projects
docs/                   shortcuts, tool notes, troubleshooting
scripts/                git-clone-bare-for-worktrees
```

## Troubleshooting

- **A package failed.** The summary at the end names it. Re-run `./install.sh`;
  for mise tools, `mise install` retries just those.
- **A tool is missing in a new shell.** Run `mise doctor`, then `exec zsh`. After
  replacing a tool by hand, `rm -rf ~/.cache/zsh` rebuilds the cached init.
- **Zed shows the default theme.** The Tokyo Night extension installs on first
  launch; give it a minute online.
- **Arch: `zed` not found.** The package names the CLI `zeditor`; `install.sh`
  links `~/.local/bin/zed` to it.

More in [docs/troubleshooting/common-issues.md](docs/troubleshooting/common-issues.md)
and the rest of [docs/](docs/README.md).

## License

MIT
