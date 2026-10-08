# Theme & UI Consistency

## Tokyo Night Storm Theme

### Why Tokyo Night Storm?

**Technical Benefits**:
1. **Optimal contrast ratios**: WCAG AA compliant
2. **Reduced eye strain**: Blue light minimized
3. **Semantic colors**: Consistent meaning across tools
4. **Wide support**: Available for 100+ applications

**Color Psychology**:
- Dark blue background (#24283b): Calming, professional
- Purple accents (#bb9af7): Creative, distinctive
- Blue highlights (#7aa2f7): Trust, stability
- Balanced palette: Not too vibrant, not too muted

### Color Palette

```
Background:     #24283b (Dark Blue)
Foreground:     #c0caf5 (Light Blue)
Selection:      #2e3c64 (Lighter Blue)
Cursor:         #c0caf5 (Light Blue)
Comments:       #565f89 (Gray Blue)

Black:          #1d202f / #414868
Red:            #f7768e (Soft Red)
Green:          #9ece6a (Soft Green)
Yellow:         #e0af68 (Warm Yellow)
Blue:           #7aa2f7 (Bright Blue)
Magenta:        #bb9af7 (Purple)
Cyan:           #7dcfff (Sky Blue)
White:          #a9b1d6 / #c0caf5

Special:
Git Added:      #9ece6a
Git Modified:   #7aa2f7
Git Deleted:    #f7768e
URL:            #73daca (Teal)
```

## Applying Theme Consistently

### Terminal (Kitty)
```conf
# Automatic theme loading
include tokyonight_storm.conf

# Transparency for depth
background_opacity 0.95
background_blur 64
```

### Shell (Starship)
```toml
# Matching colors in prompt (palette from folke/tokyonight.nvim, storm)
palette = "tokyonight_storm"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[directory]
style = "bold blue"

[git_branch]
style = "bold magenta"
```

### Editors

**Zed** (theme from the `tokyo-night` extension, installed on first launch):
```json
{
  "theme": "Tokyo Night Storm",
  "icon_theme": "Catppuccin Macchiato",
  "buffer_font_family": "CaskaydiaCove Nerd Font",
  "buffer_font_size": 14
}
```

**Neovim**:
```lua
vim.cmd[[colorscheme tokyonight-storm]]
vim.g.tokyonight_style = "storm"
vim.g.tokyonight_transparent = true
```

### System Integration

**macOS**:
- Terminal.app profiles
- iTerm2 color presets

**Linux (KDE)**:
- Konsole color schemes
- Kate/KDevelop themes
- System color integration via Kvantum

### Application Configs

**bat (better cat)**:
```bash
export BAT_THEME="TokioNight"
```

**git-delta**:
```gitconfig
[delta]
    syntax-theme = "TokioNight"
    dark = true
```

**fzf**:
```bash
# Tokyo Night Storm, from folke/tokyonight.nvim extras/fzf
export FZF_DEFAULT_OPTS='
  --color=bg+:#2e3c64,bg:#1f2335,gutter:#1f2335,border:#29a4bd
  --color=fg:#c0caf5,hl:#2ac3de,hl+:#2ac3de,query:#c0caf5:regular
  --color=header:#ff9e64,info:#545c7e,separator:#ff9e64,scrollbar:#29a4bd
  --color=marker:#ff007c,pointer:#ff007c,prompt:#2ac3de,spinner:#ff007c
'
```

## Font Selection

### CaskaydiaCove Nerd Font

**Why this font?**
1. **Ligature support**: Better code readability
2. **Nerd Font icons**: Git status, file types
3. **Clear at all sizes**: 10pt to 24pt
4. **Monospace precision**: Perfect alignment
5. **Wide character support**: Unicode, emoji

**Alternatives included**:
- JetBrains Mono Nerd Font: Slightly taller
- Both installed for user preference

### Font Configuration

**Consistent sizing**:
- Terminal: 14pt (default)
- Editors: 14pt
- System monospace: 13pt

**Line height**: 110% for better readability

## UI Principles

### 1. Minimal Chrome
- Hide unnecessary toolbars
- Borderless windows where possible
- Focus on content, not UI

### 2. Consistent Spacing
- 10px padding in terminals
- Standard margins in editors
- Uniform gap between elements

### 3. Semantic Colors
- Red: Errors, deletions
- Green: Success, additions
- Yellow: Warnings, modifications
- Blue: Information, links
- Purple: Special, keywords

### 4. Animation Restraint
- Subtle transitions (200ms)
- No bouncing/sliding
- Fade effects only
- Reduced motion option

## Platform-Specific Adaptations

### macOS
- Respect system dark mode
- Integrate with accent colors
- Follow native spacing guidelines
- Support native fullscreen

### Linux (KDE)
- Match Breeze Dark style
- Integrate with Plasma themes
- Respect system font settings
- Support Wayland transparency

## Creating Custom Themes

### Theme Generator Script
```bash
#!/usr/bin/env bash
# Generate Tokyo Night theme for new tool

generate_theme() {
    local tool=$1
    cat > "$HOME/.config/$tool/tokyonight.theme" << EOF
# Tokyo Night Storm Theme for $tool
background=#24283b
foreground=#c0caf5
selection=#2e3c64
cursor=#c0caf5
# ... rest of colors
EOF
}
```

### Conversion Tools
- **pywal**: Generate from wallpaper
- **vivid**: LS_COLORS generation
- **base16**: Universal theme framework

## Accessibility Considerations

### Contrast Ratios
- Normal text: 7:1 minimum
- Large text: 4.5:1 minimum
- UI elements: 3:1 minimum

### Color Blindness
- Avoid red/green only distinctions
- Use shapes/icons as secondary indicators
- Test with color blindness simulators

### Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Maintaining Consistency

### Theme Checklist
When adding new tools:
1. ✓ Check for Tokyo Night theme
2. ✓ Use CaskaydiaCove NF font
3. ✓ Match transparency settings
4. ✓ Apply consistent keybindings
5. ✓ Test in both light/dark environments

### Regular Audits
```bash
# Check theme consistency
find ~/.config -name "*theme*" -o -name "*color*" | \
  xargs grep -l "tokyo\|night" | sort

# Verify font usage
grep -r "font.*=\|fontFamily" ~/.config | \
  grep -v "CaskaydiaCove"
```

## Future Considerations

### Dynamic Themes
- Time-based switching (day/night)
- Activity-based themes
- Project-specific colors

### Theme Sync
- Dotfile management
- Cloud sync solutions
- Version control

### New Tools
Priority for tools with:
1. Native Tokyo Night theme
2. Configurable colors
3. Theme import/export
4. API for theming

## Benefits Realized

1. **Reduced context switching**: Same colors everywhere
2. **Faster recognition**: Semantic color meaning
3. **Less eye strain**: Optimized contrast
4. **Professional appearance**: Cohesive environment
5. **Better focus**: Minimal distractions