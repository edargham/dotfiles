#!/bin/bash
# Power menu, rendered with rofi so the cyberpunk palette lives only in
# rofi/config.rasi instead of 16 hand-passed bemenu colour flags. Icons are fed
# through rofi's dmenu icon protocol (LABEL\0icon\x1fICON-NAME) so they render in
# the element-icon slot — the same path the app launcher uses — instead of Nerd
# Font glyphs embedded in the label text, which sat inside the row and looked
# indented. Icon names are freedesktop standard, resolved via the Papirus theme
# set in rofi/config.rasi. Destructive actions require a confirmation pick.

set -euo pipefail

menu() {
    # $1 = prompt. Entries arrive on stdin as rofi icon rows (NUL/US separated).
    rofi -dmenu -i -p "$1" -theme-str 'listview { lines: 6; } window { width: 20%; }'
}

confirm() {
    # Returns success only if the user explicitly picks "Yes".
    local answer
    answer=$(printf '%s\0icon\x1f%s\n' \
        'Yes' 'object-select' \
        'No'  'window-close' | menu "$1")
    [[ "$answer" == Yes ]]
}

CHOICE=$(printf '%s\0icon\x1f%s\n' \
    'Lock'      'system-lock-screen' \
    'Suspend'   'system-suspend' \
    'Logout'    'system-log-out' \
    'Hibernate' 'system-hibernate' \
    'Restart'   'system-reboot' \
    'Shutdown'  'system-shutdown' | menu 'Power')

case "$CHOICE" in
    Lock)      hyprlock ;;
    Suspend)   systemctl suspend ;;
    Logout)    confirm 'Log out?'   && hyprctl dispatch exit ;;
    Hibernate) confirm 'Hibernate?' && systemctl hibernate ;;
    Restart)   confirm 'Reboot?'    && systemctl reboot ;;
    Shutdown)  confirm 'Shut down?' && systemctl poweroff ;;
esac
