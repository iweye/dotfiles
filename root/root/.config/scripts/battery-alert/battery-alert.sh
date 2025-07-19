#!/bin/sh

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Possible values: NONE, FULL, LOW, CRITICAL
last="NONE"
critical=10
low=25

while true; do

  # If battery is plugged, do stuff
  battery="/sys/class/power_supply/BAT0"
  if [ -d $battery ]; then

    capacity=$(cat $battery/capacity)
    status=$(cat $battery/status)

    # If battery full and not already warned about that
    if [ "$last" != "FULL" ] && [ "$status" = "Full" ]; then
      playerctl pause
      notify-send -i "$dir/full.png" "Battery full"
      sink=$(pactl get-default-sink)
      old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
      pactl set-sink-volume "$sink" 100%
      paplay "$dir/full.ogg"
      pactl set-sink-volume "$sink" "$old_vol"
      last="FULL"
    fi

    # If low and discharging
    if [ "$last" != "LOW" ] && [ "$last" != "CRITICAL" ]  && \
       [ "$status" = "Discharging" ] && [ $capacity -le $low ]; then
      playerctl pause
      notify-send -i "$dir/low.png" "Battery low: $capacity%"
      sink=$(pactl get-default-sink)
      old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
      pactl set-sink-volume "$sink" 100%
      paplay "$dir/warn.ogg"
      pactl set-sink-volume "$sink" "$old_vol"
      last="LOW"
	fi

	# If critical level and discharging
	if [ "$last" = "LOW" ] && [ "$status" = "Discharging" ] && \
	   [ $capacity -le $critical ]; then
    playerctl pause
	  notify-send -i "$dir/critical.png" "Battery critical: $capacity%"
    sink=$(pactl get-default-sink)
    old_vol=$(pactl get-sink-volume "$sink" | awk '{print $5}' | head -n1)
    pactl set-sink-volume "$sink" 100%
    paplay "$dir/warn.ogg"
    pactl set-sink-volume "$sink" "$old_vol"
    last="CRITICAL"
    fi
  fi
  sleep 60

done
