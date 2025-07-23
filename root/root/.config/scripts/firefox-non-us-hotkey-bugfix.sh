#!/bin/bash

keyboard_id=14
ctrl_l=37
layout_file="/tmp/prev_layout.txt"

/usr/bin/stdbuf -oL /usr/bin/xinput test "$keyboard_id" | while read -r _action _type keycode; do
    if [[ "$_action" == "key" && "$_type" == "press" && "$keycode" == "$ctrl_l" ]]; then
        /usr/bin/setxkbmap -query | /usr/bin/awk '/layout:/ {print $2}' > "$layout_file"
        /usr/bin/setxkbmap us
    elif [[ "$_action" == "key" && "$_type" == "release" && "$keycode" == "$ctrl_l" ]]; then
        [[ -f "$layout_file" ]] && /usr/bin/setxkbmap "$(/usr/bin/cat "$layout_file")"
    fi
done
