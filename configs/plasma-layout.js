// KDE Plasma layout configuration for developers
// This script sets up a developer-friendly desktop layout

// Set up panels
var panel = new Panel
panel.height = 32
panel.location = "bottom"
panel.alignment = "center"

// Add widgets to panel
panel.addWidget("org.kde.plasma.kickoff")
panel.addWidget("org.kde.plasma.pager")
panel.addWidget("org.kde.plasma.taskmanager")
panel.addWidget("org.kde.plasma.systemtray")
panel.addWidget("org.kde.plasma.digitalclock")
panel.addWidget("org.kde.plasma.showdesktop")

// Configure desktop
var desktops = desktopsArray
for (var i = 0; i < desktops.length; i++) {
    var desktop = desktops[i]
    desktop.wallpaperPlugin = "org.kde.image"
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"]
    desktop.writeConfig("Image", "file:///usr/share/wallpapers/Next/contents/images/1920x1080.png")
}

// Set up activities if available
if (typeof activities !== 'undefined') {
    activities.setCurrentActivity("main")
}

print("Developer desktop layout configured successfully!")