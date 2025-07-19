#!/usr/bin/env fish
# source: https://github.com/Yutsuten/linux-config/blob/main/system/utilities/wp-volume.fish

function show_help
    echo 'Usage: wp-volume [toggle-mute|toggle-mic-mute|VOL[%][-/+]]' >&2
    echo >&2
    echo '  Synopsis:' >&2
    echo '    Change volume, toggle mute state, or mute microphone.' >&2
    echo >&2
    echo '  Options:' >&2
    echo '    -h, --help          Show list of command-line options' >&2
    echo >&2
    echo '  Positional arguments:' >&2
    echo '    toggle-mute         Toggle output mute state' >&2
    echo '    toggle-mic-mute     Toggle microphone mute state' >&2
    echo '    VOL[%][-/+]         Increase or decrease output volume' >&2
end

if test (count $argv) -ne 1
    show_help
    exit 1
end

set arg $argv[1]

if test $arg = "-h" -o $arg = "--help"
    show_help
    exit 0
end

set default_sink (pactl get-default-sink)
set default_source (pactl get-default-source)

if test $arg = "toggle-mute"
    pactl set-sink-mute $default_sink toggle
else if test $arg = "toggle-mic-mute"
    pactl set-source-mute $default_source toggle
    set mic_muted (pactl get-source-mute $default_source | string match -r 'Mute: yes')
    if test -n "$mic_muted"
        notify-send --replace-id 9998 --app-name wp-volume --icon microphone-sensitivity-muted-symbolic --urgency low 'Microphone: Muted'
    else
        notify-send --replace-id 9998 --app-name wp-volume --icon microphone-sensitivity-high-symbolic --urgency low 'Microphone: Active'
    end
    exit 0
else
    if not pactl set-sink-volume $default_sink $arg &>/dev/null
        show_help
        exit 1
    end
end

set vol_info (pactl get-sink-volume $default_sink)
set mute_info (pactl get-sink-mute $default_sink)

set volume (string match -r '\d+%' $vol_info | head -n1 | tr -d '%')
set muted (string match -r 'Mute: yes' $mute_info)

if test -n "$muted"
    notify-send --replace-id 9999 --app-name wp-volume --icon audio-volume-muted-symbolic --urgency low 'Volume: Muted'
else
    if test $volume -le 33
        set icon audio-volume-low-symbolic
    else if test $volume -le 66
        set icon audio-volume-medium-symbolic
    else
        set icon audio-volume-high-symbolic
    end
    notify-send --replace-id 9999 --app-name wp-volume --icon $icon --urgency low -h "int:value:$volume" "Volume: $volume%"
end
