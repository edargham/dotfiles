#!/bin/bash
# Power menu, rendered with rofi so the cyberpunk palette lives only in
# rofi/config.rasi instead of 16 hand-passed bemenu colour flags. Destructive
# actions (shutdown/reboot/logout/hibernate) require a confirmation pick.

set -euo pipefail

menu() {
    # $1 = prompt, remaining args on stdin are the newline-separated entries.
    rofi -dmenu -i -p "$1" -theme-str 'listview { lines: 6; } window { width: 20%; }'
}

confirm() {
    # Returns success only if the user explicitly picks "Yes".
    local answer
    answer=$(printf ' Yes\n No' | menu "$1")
    [[ "$answer" == *Yes* ]]
}

CHOICE=$(printf '%s\n' \
    ' Lock' \
    ' Suspend' \
    ' Logout' \
    ' Hibernate' \
    ' Restart' \
    ' Shutdown' | menu 'Power')

case "$CHOICE" in
    *Lock*)      hyprlock ;;
    *Suspend*)   systemctl suspend ;;
    *Logout*)    confirm 'Log out?'   && hyprctl dispatch exit ;;
    *Hibernate*) confirm 'Hibernate?' && systemctl hibernate ;;
    *Restart*)   confirm 'Reboot?'    && systemctl reboot ;;
    *Shutdown*)  confirm 'Shut down?' && systemctl poweroff ;;
esac
