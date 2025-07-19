#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: wp-volume [toggle-mute|toggle-mic-mute|VOL%%[+/-]]\n");
        return 1;
    }

    const char *arg = argv[1];

    if (!strcmp(arg, "toggle-mute")) {
        system("pactl set-sink-mute @DEFAULT_SINK@ toggle");
    } else if (!strcmp(arg, "toggle-mic-mute")) {
        system("pactl set-source-mute @DEFAULT_SOURCE@ toggle");
        FILE *mic = popen("pactl get-source-mute @DEFAULT_SOURCE@", "r");
        char buf[64]; fgets(buf, sizeof(buf), mic); pclose(mic);
        system(strstr(buf, "yes") ?
            "notify-send --replace-id 9998 --app-name 'system' --icon microphone-sensitivity-muted-symbolic --urgency low 'Microphone: Muted'" :
            "notify-send --replace-id 9998 --app-name 'system' --icon microphone-sensitivity-high-symbolic --urgency low 'Microphone: Active'");
        return 0;
    } else {
        char cmd[128];
        snprintf(cmd, sizeof(cmd), "pactl set-sink-volume @DEFAULT_SINK@ %s", arg);
        if (system(cmd)) return 1;
    }

    FILE *v = popen("pactl get-sink-volume @DEFAULT_SINK@", "r");
    char buf[256]; fgets(buf, sizeof(buf), v); pclose(v);
    FILE *m = popen("pactl get-sink-mute @DEFAULT_SINK@", "r");
    char mute[64]; fgets(mute, sizeof(mute), m); pclose(m);

    if (strstr(mute, "yes")) {
        system("notify-send --replace-id 9999 --app-name 'system' --icon audio-volume-muted-symbolic --urgency low 'Volume: Muted'");
    } else {
        int vol = 0;
        char *p = strstr(buf, "/"); if (p) sscanf(p, "/ %d%%", &vol);
        const char *icon = vol <= 33 ? "audio-volume-low-symbolic" :
                           vol <= 66 ? "audio-volume-medium-symbolic" :
                                       "audio-volume-high-symbolic";
        char notify[256];
        snprintf(notify, sizeof(notify),
            "notify-send --replace-id 9999 --app-name 'system' --icon %s --urgency low -h int:value:%d 'Volume: %d%%'",
            icon, vol, vol);
        system(notify);
    }

    return 0;
}
