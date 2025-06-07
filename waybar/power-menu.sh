#!/bin/bash
CHOICE=$(printf "  Shutdown  \n  Restart  \n  Logout  \n  Suspend  \n  Hibernate  " | bemenu -p "  Power Menu  " --fn "JetBrainsMono Nerd Font 12" -H 31 --hp 8 --nb "#000000ab" --nf "#00ffff" --ab "#000000ab" --af "#00ffff" --tb "#ff0040" --tf "#000000" --fb "#000000ab" --ff "#00ffff" --hb "#ffff00ab" --hf "#000000" --sb "#ffff00ab" --sf "#000000" --scb "#000000ab" --scf "#ffff00")

case "$CHOICE" in
    *"Shutdown"*) poweroff ;;
    *"Restart"*) reboot ;;
    *"Logout"*) hyprctl dispatch exit ;;
    *"Suspend"*) systemctl suspend ;;
    *"Hibernate"*) systemctl hibernate ;;
esac