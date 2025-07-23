#!/bin/bash

STATE_FILE="$HOME/.config/waybar/.night-mode-state"

# Check current state (compatible with both waybar and keybinding usage)
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "on" ]; then
    # Night mode is on, switch to day mode
    pkill -9 hyprsunset
    sleep 0.1
    hyprsunset -t 6000 &
    echo "off" > "$STATE_FILE"
    # notify-send "Night Mode" "Disabled" -i weather-clear-night 2>/dev/null || true
else
    # Night mode is off, switch to night mode  
    pkill -9 hyprsunset
    sleep 0.1
    hyprsunset -t 3400 &
    echo "on" > "$STATE_FILE"
    # notify-send "Night Mode" "Enabled" -i weather-clear-night 2>/dev/null || true
fi
