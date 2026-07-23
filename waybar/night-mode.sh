#!/bin/bash
# Waybar module: render the night-mode (blue-light filter) icon.
#
# Single source of truth is hyprsunset's own IPC (`hyprctl hyprsunset
# temperature`), queried live each poll. No state file -- the previous
# implementation scraped `ps aux | awk '{print $13}'`, which broke on any
# argument-order change and threw "integer expression expected" whenever
# hyprsunset was not running (empty string compared with -lt).
#
# hyprsunset is managed by hyprsunset.service; day mode is 6000K, night ~3400K.
# Anything below DAY_TEMP counts as "on".

DAY_TEMP=6000

TEMP=$(hyprctl hyprsunset temperature 2>/dev/null)

# "on" only when we got a clean integer strictly below day temp.
if [[ "$TEMP" =~ ^[0-9]+$ ]] && (( TEMP < DAY_TEMP )); then
    ICON="󰖔"  # nf-md-weather_night (moon)
    TOOLTIP="Night mode: ON (${TEMP}K) — click to disable"
    CLASS="night-mode-on"
else
    ICON="󰖙"  # nf-md-weather_sunny (sun)
    TOOLTIP="Night mode: OFF — click to enable"
    CLASS="night-mode-off"
fi

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$ICON" "$TOOLTIP" "$CLASS"
