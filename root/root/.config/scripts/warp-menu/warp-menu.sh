#!/usr/bin/env bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Script to toggle WARP service (Cloudflare) via rofi menu
## Author: адаптовано під запит користувача

rofi_command="rofi -no-config -theme $dir/warp-menu.rasi"

# Options
warp_on=" ON"
warp_off=" OFF"

# Variable passed to rofi
options="$warp_on\n$warp_off"

chosen="$(echo -e "$options" | $rofi_command -p "WARP" -dmenu -selected-row 0)"

case $chosen in
    $warp_on)
        echo "[INFO] Enabling WARP..."
        sudo systemctl start warp-svc
        sleep 1
        warp-cli connect
        notify-send -i "$dir/on.png" "WARP увімкнено"
        sink=$(pactl get-default-sink)
        old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
        pactl set-sink-volume "$sink" 100%
        paplay "$dir/on.ogg"
        pactl set-sink-volume "$sink" "$old_vol"
        ;;
    $warp_off)
        echo "[INFO] Disabling WARP..."
        warp-cli disconnect
        sleep 1
        sudo systemctl stop warp-svc
        notify-send -i "$dir/off.png" "WARP вимкнено"
        sink=$(pactl get-default-sink)
        old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
        pactl set-sink-volume "$sink" 100%
        paplay "$dir/off.ogg"
        pactl set-sink-volume "$sink" "$old_vol"
        ;;
esac
