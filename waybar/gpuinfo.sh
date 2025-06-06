#!/bin/bash
# Get GPU utilization and temperature
GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1)
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)

# Choose icon based on utilization (optional)
if [ "$GPU_UTIL" -lt 20 ]; then
    ICON="󰢮"  # nf-md-gpu (idle)
elif [ "$GPU_UTIL" -lt 50 ]; then
    ICON="󰾲"  # nf-md-graphics_card (moderate)
elif [ "$GPU_UTIL" -lt 80 ]; then
    ICON="󰓅"  # nf-fa-fire (high)
else
    ICON="󰈸"  # nf-md-fire (very high, looks like "flame" for huge effort)
fi

# Output JSON for Waybar
echo "{\"text\": \"$ICON $GPU_UTIL%  $GPU_TEMP°C\", \"tooltip\": \"GPU Utilization: $GPU_UTIL% | Temp: $GPU_TEMP°C\"}"
