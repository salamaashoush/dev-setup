#!/usr/bin/env bash

# Rofi Developer Menu
# Quick access to development tools and projects

# Define development tools (command to check : display name : launch command)
declare -A dev_tools=(
    ["  Zed"]="zed"
    ["  Kitty"]="kitty"
    ["  Lazygit"]="lazygit"
    ["  Btop"]="btop"
    ["  Docker Desktop"]="docker-desktop"
    ["  GitHub Desktop"]="github-desktop"
)

# Launch commands (may differ from check command)
declare -A dev_launch=(
    ["  Zed"]="zed"
    ["  Kitty"]="kitty"
    ["  Lazygit"]="kitty -e lazygit"
    ["  Btop"]="kitty -e btop"
    ["  Docker Desktop"]="docker-desktop"
    ["  GitHub Desktop"]="github-desktop"
)

# Define project directories
declare -A projects=(
    ["  Home Directory"]="$HOME"
    ["  Projects"]="$HOME/Projects"
    ["  Documents"]="$HOME/Documents"
    ["  Downloads"]="$HOME/Downloads"
    ["  Config Files"]="$HOME/.config"
)

# Create menu options - only include tools that exist
tools_menu=""
for tool in "${!dev_tools[@]}"; do
    cmd="${dev_tools[$tool]}"
    if command -v "$cmd" &>/dev/null; then
        tools_menu+="$tool\n"
    fi
done

# Only include directories that exist
projects_menu=""
for project in "${!projects[@]}"; do
    dir="${projects[$project]}"
    if [[ -d "$dir" ]]; then
        projects_menu+="$project\n"
    fi
done

# Combined menu
menu="=== Development Tools ===\n$tools_menu\n=== Quick Access ===\n$projects_menu"

# Show menu
chosen="$(echo -e "$menu" | rofi -dmenu -p "Developer Menu" -theme-str 'window {width: 600px;} listview {lines: 15;}')"

# Handle selection
if [[ -n "$chosen" ]]; then
    # Check if it's a tool
    for tool in "${!dev_launch[@]}"; do
        if [[ "$chosen" == "$tool" ]]; then
            ${dev_launch[$tool]} &
            exit 0
        fi
    done
    
    # Check if it's a project directory
    for project in "${!projects[@]}"; do
        if [[ "$chosen" == "$project" ]]; then
            # Open in file manager
            if command -v dolphin &>/dev/null; then
                dolphin "${projects[$project]}" &
            elif command -v nautilus &>/dev/null; then
                nautilus "${projects[$project]}" &
            elif command -v thunar &>/dev/null; then
                thunar "${projects[$project]}" &
            else
                xdg-open "${projects[$project]}" &
            fi
            exit 0
        fi
    done
fi