# Productivity Tools Documentation

## System Monitoring

### btop
**Description**: Modern resource monitor with mouse support  
**Command**: `btop`  
**Key Features**:
- CPU, memory, network, and disk monitoring
- Process tree view
- Kill processes interactively
- Mouse support for easy navigation
- Customizable themes (Tokyo Night included)

**Shortcuts**:
- `P` → Sort by CPU
- `M` → Sort by memory
- `F2` → Settings
- `F9` → Kill process
- `/` → Search process

### topgrade
**Description**: Upgrade all the things with one command  
**Command**: `topgrade`  
**Config**: `~/.config/topgrade.toml`

**What it updates**:
- System packages (Homebrew/yay)
- Programming language packages
- Git repositories
- Editor plugins
- Shell plugins
- Firmware (if applicable)

### System Monitors (GUI)
- **Stats** (macOS): Menu bar system monitor
- **iStat Menus** (macOS): Advanced menu bar stats
- **plasma-systemmonitor** (Linux): KDE system monitor

## Clipboard Management

### macOS
**Maccy**
- **Shortcut**: `Cmd+Shift+C`
- **Features**: Search, pin items, ignore apps
- **Config**: Preferences → set history size

**CopyQ** (Cross-platform alternative)
- Advanced scripting
- Tabs for organization
- Command execution

### Linux
**cliphist** (Wayland)
- Integrates with Rofi: `Alt+Shift+C`
- Persistent history
- Image support

**CopyQ**
- Same as macOS version
- Works on X11 and Wayland

## App Launchers

### Raycast (macOS)
**Primary Functions**:
- App launching: `Cmd+Space`
- Window management: `Cmd+Opt+Space`
- Clipboard history: `Cmd+Opt+V`
- Emoji picker: `Cmd+Opt+E`
- Calculator: Type math in launcher
- System commands: Lock, sleep, restart
- Custom scripts: Bash, Python, Swift

**Extensions**:
- GitHub
- Linear
- Spotify
- Brew
- Kill Process
- Color Picker

### Rofi (Linux)
**Config**: `~/.config/rofi/`  
**Scripts**: Custom menus for everything

**Shortcuts**:
- `Alt+Space` → App launcher
- `Alt+Shift+C` → Clipboard
- `Alt+Shift+P` → Power menu
- `Alt+Shift+D` → Dev projects menu
- `Alt+Shift+=` → Calculator
- `Alt+Shift+E` → Emoji picker
- `Alt+Shift+W` → Web search

**Why Rofi?**
- Highly scriptable
- Wayland support
- Fast and lightweight
- Extensive theming

## Window Management

### Rectangle (macOS)
**Free and open source**  
**Default Shortcuts**:
- `Ctrl+Opt+Left` → Left half
- `Ctrl+Opt+Right` → Right half
- `Ctrl+Opt+Enter` → Maximize
- `Ctrl+Opt+C` → Center
- `Ctrl+Opt+D` → Restore

### KDE Window Management (Linux)
**Built-in to KWin**:
- `Meta+Left/Right` → Tile half
- `Meta+Up` → Maximize
- `Meta+Down` → Minimize
- Custom tiling with KWin scripts

## Screenshot Tools

### macOS
**Built-in**:
- `Cmd+Shift+3` → Full screen
- `Cmd+Shift+4` → Selection
- `Cmd+Shift+5` → Options menu

**CleanShot X** (Premium)
- Scrolling capture
- Annotation tools
- Cloud upload
- Screen recording
- OCR text extraction

### Linux
**Flameshot**:
- Feature-rich annotation
- Upload to cloud
- Pin screenshots

**grim + slurp** (Wayland):
- `grim` → Screenshot
- `slurp` → Select region
- Scriptable workflow

## Note Taking

### Obsidian
**Description**: Knowledge base with bidirectional linking  
**Features**:
- Markdown-based
- Graph view
- Plugins ecosystem
- Vim mode available
- Mobile sync

**Workflow**:
```bash
# Quick note
echo "# $(date +%Y-%m-%d)" > ~/Obsidian/daily/$(date +%Y-%m-%d).md
obsidian
```

## Quick Calculators

### Command Line
**bc**: Basic calculator
```bash
echo "2 + 2" | bc
echo "scale=2; 22/7" | bc  # 2 decimal places
```

**libqalculate** (qalc): Advanced calculator
```bash
qalc "5 USD to EUR"
qalc "sqrt(2)"
qalc "integrate(x^2, x)"
```

### GUI/Launcher Integration
- Raycast: Type math directly
- Rofi calc: `Alt+Shift+=`
- KRunner: `Alt+F2` then type math

## Time Management

### Pomotroid
**Description**: Pomodoro timer  
**Features**:
- 25 min focus / 5 min break
- Customizable intervals
- Statistics tracking
- Minimal UI

## Media Tools

### Recording
**OBS Studio**:
- Screen recording
- Streaming
- Scene composition
- Plugin support

**Linux specific**:
- wlrobs: Wayland support
- obs-pipewire-audio: Audio capture

### Image Processing
**ImageMagick**: Command-line processing
```bash
convert input.png -resize 50% output.png
convert *.jpg combined.pdf
identify image.jpg  # Get info
```

**FFmpeg**: Video/audio processing
```bash
ffmpeg -i input.mp4 -c:v libx264 output.mp4
ffmpeg -i input.mp4 -ss 00:01:00 -t 00:00:30 output.mp4
```

### Optimization Tools
**Image optimization**:
- `optipng`: PNG optimization
- `gifsicle`: GIF optimization

```bash
optipng -o7 image.png
gifsicle -O3 animation.gif -o optimized.gif
```

## Network Analysis

### Wireshark
**Description**: Network protocol analyzer  
**Usage**: Packet capture and analysis  
**Filters**:
```
http.request.method == "GET"
tcp.port == 80
ip.addr == 192.168.1.1
```

### Command Line Tools
**mtr**: Traceroute + ping
```bash
mtr google.com
```

**bandwhich**: Bandwidth utilization
```bash
sudo bandwhich
```

**oha**: HTTP load testing
```bash
oha -n 10000 -c 100 https://example.com
```

## AI/ML Tools

### Ollama
**Description**: Run LLMs locally  
**Usage**:
```bash
ollama pull llama2
ollama run llama2
```

### LM Studio (macOS)
**GUI for local LLMs**:
- Model marketplace
- Chat interface
- API server mode
- Resource monitoring

### Claude Code
**Your AI assistant**:
```bash
claude --help
claude "explain this code"
```

## Communication

### Slack
**Shortcuts**:
- `Cmd/Ctrl+K` → Quick switcher
- `Cmd/Ctrl+/` → Shortcuts list
- `Cmd/Ctrl+Shift+D` → Toggle sidebar
- `Cmd/Ctrl+.` → Toggle right sidebar

### Discord
**Shortcuts**:
- `Ctrl+Alt+Up/Down` → Navigate servers
- `Alt+Up/Down` → Navigate channels
- `Ctrl+Enter` → Quick reply
- `Ctrl+/` → Shortcuts list

## Productivity Workflows

### Quick Access Setup
1. **Pin frequently used apps** to dock/taskbar
2. **Create launcher shortcuts** for common tasks
3. **Set up clipboard manager** with 30-day history
4. **Configure screenshot shortcuts** with annotation

### Daily Workflow
```bash
# Morning routine
topgrade                    # Update everything
obsidian                   # Review notes
pomotroid                  # Start focus timer

# During work
Cmd+Space → app name       # Quick launch
Cmd+Opt+V → find snippet   # Clipboard history
btop                       # Check resources

# End of day
lazygit                    # Commit work
topgrade --cleanup         # Clean caches
```

### Automation Ideas
1. **Raycast scripts** for repetitive tasks
2. **Keyboard Maestro** (macOS) for complex automation
3. **KDE Activities** for context switching
4. **direnv** for project-specific environments

## Performance Tips

1. **Disable animations** in launchers for speed
2. **Limit clipboard history** to 1000 items
3. **Use keyboard shortcuts** over mouse
4. **Create templates** in Obsidian
5. **Set up quick capture** for notes/tasks