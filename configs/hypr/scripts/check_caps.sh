#!/usr/bin/env bash
# Caps lock indicator for Hyprland/Wayland

# Method 1: Check LED brightness (most reliable on Linux)
for led in /sys/class/leds/*capslock*/brightness; do
    if [ -f "$led" ]; then
        if [ "$(cat "$led")" = "1" ]; then
            echo "CAPS LOCK"
            exit 0
        fi
    fi
done

# Method 2: Fallback using hyprctl (if available)
if command -v hyprctl &> /dev/null; then
    if hyprctl devices -j | grep -q '"capsLock":true'; then
        echo "CAPS LOCK"
        exit 0
    fi
fi

echo ""