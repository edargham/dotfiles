#!/bin/bash

STATE_FILE="$HOME/.config/waybar/.night-mode-state"

# Always check current hyprsunset temperature to detect keybinding changes
if pgrep -x "hyprsunset" > /dev/null; then
    # Check current temperature by looking at process arguments
    CURRENT_TEMP=$(ps aux | grep "hyprsunset -t" | grep -v grep | awk '{print $13}')
    if [ "$CURRENT_TEMP" = "3400" ] || [ "$CURRENT_TEMP" -lt "5000" ]; then
        ACTUAL_STATE="on"
    else
        ACTUAL_STATE="off"
    fi
else
    ACTUAL_STATE="off"
fi

# Check if state file exists and matches actual state
if [ -f "$STATE_FILE" ]; then
    STORED_STATE=$(cat "$STATE_FILE")
    # If stored state doesn't match actual state, update it (keybinding was used)
    if [ "$STORED_STATE" != "$ACTUAL_STATE" ]; then
        echo "$ACTUAL_STATE" > "$STATE_FILE"
    fi
    STATE="$ACTUAL_STATE"
else
    # No state file, create one based on current state
    STATE="$ACTUAL_STATE"
    echo "$STATE" > "$STATE_FILE"
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
