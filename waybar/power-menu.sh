#!/bin/bash
CHOICE=$(printf "  Shutdown  \n  Restart  \n  Lock  \n  Logout  \n  Suspend  \n  Hibernate  " | bemenu -p "  Power Menu  " --fn "JetBrainsMono Nerd Font 12" -H 32 --hp 8 --nb "#000000ab" --nf "#5de5ff" --ab "#000000ab" --af "#5de5ff" --tb "#d946ef" --tf "#000000" --fb "#000000ab" --ff "#5de5ff" --hb "#c7f5ffab" --hf "#000000" --sb "#c7f5ffab" --sf "#000000" --scb "#000000ab" --scf "#c7f5ff")

case "$CHOICE" in
    *"Shutdown"*) poweroff ;;
    *"Restart"*) reboot ;;
    *"Lock"*) hyprlock ;;
    *"Logout"*) hyprctl dispatch exit ;;
    *"Suspend"*) systemctl suspend ;;
    *"Hibernate"*) systemctl hibernate ;;
esac