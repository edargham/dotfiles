#!/bin/bash
# Waybar module: NVIDIA GPU utilization + temperature.
#
# One nvidia-smi call per poll (the previous version ran it twice every 2s).
# Guards the failure case: if the driver isn't ready or nvidia-smi errors, emit
# a placeholder instead of feeding an empty string into a `-lt` test (which
# throws "integer expression expected").

read -r GPU_UTIL GPU_TEMP < <(
    nvidia-smi --query-gpu=utilization.gpu,temperature.gpu \
        --format=csv,noheader,nounits 2>/dev/null \
    | head -n1 | tr -d ','
)

if ! [[ "$GPU_UTIL" =~ ^[0-9]+$ ]]; then
    printf '{"text": "󰢮 N/A", "tooltip": "GPU: nvidia-smi unavailable"}\n'
    exit 0
fi

if   (( GPU_UTIL < 20 )); then ICON="󰢮"   # idle
elif (( GPU_UTIL < 50 )); then ICON="󰾲"   # moderate
elif (( GPU_UTIL < 80 )); then ICON="󰓅"   # high
else                           ICON="󰈸"   # very high
fi

printf '{"text": "%s %s%%  %s°C", "tooltip": "GPU Utilization: %s%% | Temp: %s°C"}\n' \
    "$ICON" "$GPU_UTIL" "$GPU_TEMP" "$GPU_UTIL" "$GPU_TEMP"
