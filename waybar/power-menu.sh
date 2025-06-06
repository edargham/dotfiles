#!/bin/bash
CHOICE=$(printf "Shutdown\nRestart\nLogout\nSuspend\nHibernate" | bemenu -p "Power Menu" --fn "JetBrainsMono Nerd Font 12" --nb "#1e1e2e" --nf "#cdd6f4" --ab "#1e1e2e" --af "#cdd6f4" --tb "#f38ba8" --tf "#1e1e2e" --fb "#1e1e2e" --ff "#cdd6f4" --hb "#f38ba8" --hf "#1e1e2e" --sb "#f38ba8" --sf "#1e1e2e" --scb "#1e1e2e" --scf "#cdd6f4")

case "$CHOICE" in
    "Shutdown") poweroff ;;
    "Restart") reboot ;;
    "Logout") hyprctl dispatch exit ;;
    "Suspend") systemctl suspend ;;
    "Hibernate") systemctl hibernate ;;
esac

