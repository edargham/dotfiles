#!/bin/bash

STATE_FILE="$HOME/.config/waybar/.night-mode-state"

# Check state file first, fallback to process temperature detection
if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
else
    # Fallback: detect based on current temperature if hyprsunset is running
    if pgrep -x "hyprsunset" > /dev/null; then
        # Check current temperature by looking at process arguments
        CURRENT_TEMP=$(ps aux | grep "hyprsunset -t" | grep -v grep | awk '{print $13}')
        if [ "$CURRENT_TEMP" = "3400" ] || [ "$CURRENT_TEMP" -lt "5000" ]; then
            STATE="on"
            echo "on" > "$STATE_FILE"
        else
            STATE="off"
            echo "off" > "$STATE_FILE"
        fi
    else
        STATE="off"
        echo "off" > "$STATE_FILE"
    fi
fi

# Set icon and tooltip based on state
if [ "$STATE" = "on" ]; then
    ICON="󰖔"  # nf-md-weather_night (moon icon)
    TOOLTIP="Night mode: ON (Click to disable)"
    CLASS="night-mode-on"
else
    ICON="󰖙"  # nf-md-weather_sunny (sun icon)
    TOOLTIP="Night mode: OFF (Click to enable)"
    CLASS="night-mode-off"
fi

# Output JSON for Waybar
echo "{\"text\": \"$ICON\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
