#!/bin/bash
# Toggle the night-mode blue-light filter via hyprsunset IPC.
#
# Invoked from both the Waybar module's on-click and the SUPER+N keybind.
# State lives entirely in the running hyprsunset instance, so the two entry
# points can never disagree and there is no state file to race on. The old
# version did `pkill -9 hyprsunset; sleep 0.1; hyprsunset -t N &`, which killed
# the systemd-managed daemon (triggering Restart=on-failure) and raced a bare
# background process against it. IPC just retunes the daemon in place.

DAY_TEMP=6000
NIGHT_TEMP=3400

CURRENT=$(hyprctl hyprsunset temperature 2>/dev/null)

if [[ "$CURRENT" =~ ^[0-9]+$ ]] && (( CURRENT < DAY_TEMP )); then
    hyprctl hyprsunset temperature "$DAY_TEMP" >/dev/null
else
    hyprctl hyprsunset temperature "$NIGHT_TEMP" >/dev/null
fi

# Refresh the Waybar module immediately instead of waiting for the next poll.
pkill -RTMIN+10 waybar 2>/dev/null || true
