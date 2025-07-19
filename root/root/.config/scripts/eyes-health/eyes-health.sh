#!/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  sleep 1200  # 20 хвилин = 1200 секунд
  playerctl pause
  notify-send "Перерва для очей 👀" \
    "Відірви погляд на 20 секунд!" \
    --icon="$dir/eyes-emoji.png"
  sink=$(pactl get-default-sink)
  old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
  pactl set-sink-volume "$sink" 100%
  paplay "$dir/warn.ogg"
  pactl set-sink-volume "$sink" "$old_vol"
done
