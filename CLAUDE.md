# NixOS Configuration

This is a NixOS system configuration using Hyprland as the Wayland compositor.

## Directory Structure

- `./configuration.nix` - Main NixOS system configuration
- `./flake.nix` - Nix flake for reproducible builds
- `./configs/` - Application configurations (dotfiles)
  - `./configs/quickshell/` - Quickshell bar/widgets configuration
- `./scripts/` - Deployment and utility scripts
- `./wallpapers/` - Wallpaper images

## Quickshell Configuration

The Quickshell configuration (`./configs/quickshell/`) provides a top bar with widgets.

### Architecture

- **Widgets should be separated into their own files** - Each widget (clock, CPU, etc.) gets its own `.qml` file
- **All widgets must use ColorService** - The `ColorService.qml` singleton provides theme colors from `~/.config/quickshell/colors.json`
- Register new components in `qmldir`

### Key Files

- `shell.qml` - Main shell entry point, assembles the bar layout
- `ColorService.qml` - Singleton providing theme colors
- `WallpaperSelector.qml` - Wallpaper picker popup
- `ClockWidget.qml` - Time/date display widget
- `CpuWidget.qml` - CPU load average widget

### Adding New Widgets

1. Create `YourWidget.qml` in `./configs/quickshell/`
2. Use `ColorService.primary`, `ColorService.foregroundSurface`, etc. for colors
3. Register in `qmldir`: `YourWidget 1.0 YourWidget.qml`
4. Add to `shell.qml` layout

### Icon Font

Use `"FiraCode Nerd Font"` with Unicode escape sequences for icons:
```qml
Text {
    text: "\uf017" // clock icon
    font.family: "FiraCode Nerd Font"
}
```
