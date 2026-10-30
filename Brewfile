# macOS packages, installed by the packages step with `brew bundle --no-upgrade`
# (topgrade does the upgrading). CLI tools come from configs/mise/config.toml;
# Homebrew keeps what needs system integration or has no mise build for arm64.

# Shell and terminal
brew "zsh"
brew "git"
brew "eza"
brew "btop"
brew "procs"
brew "xan"
brew "mtr"
brew "nmap"
brew "bandwhich"
brew "tree"
brew "watch"
brew "asciinema"
brew "noti"
cask "ghostty"
cask "kitty"

# Fonts
cask "font-caskaydia-cove-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"
cask "font-fira-code-nerd-font"

# Containers
brew "docker"
brew "docker-buildx"
brew "docker-compose"
brew "colima"

# Media
brew "imagemagick"
brew "ffmpeg"

# Apps
cask "zed"
cask "google-chrome"
cask "discord"
cask "slack"
cask "1password"
cask "rectangle"
cask "stats"
cask "steam"
cask "obs"

# Answered during setup and passed in by install.sh
if ENV["INSTALL_GAMEDEV"] == "true"
  cask "godot"
  cask "blender"
  brew "molten-vk"
end
