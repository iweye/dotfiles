#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int get_brightness_percent() {
    FILE *fp = popen("brightnessctl g", "r");
    if (!fp) return -1;
    int current;
    fscanf(fp, "%d", &current);
    pclose(fp);

    fp = popen("brightnessctl m", "r");
    if (!fp) return -1;
    int max;
    fscanf(fp, "%d", &max);
    pclose(fp);

    if (max == 0) return -1;
    return (current * 100) / max;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: brightness [N%%+|N%%-|N%%]\n");
        return 1;
    }

    const char *arg = argv[1];
    int len = strlen(arg);

    char transformed[16];
    if (len > 1 && arg[len - 1] == '+') {
        snprintf(transformed, sizeof(transformed), "+%.*s", len - 1, arg);
    } else {
        snprintf(transformed, sizeof(transformed), "%s", arg);
    }

    char cmd[128];
    snprintf(cmd, sizeof(cmd), "brightnessctl set %s > /dev/null 2>&1", transformed);
    if (system(cmd)) return 1;

    int percent = get_brightness_percent();
    if (percent < 0) return 1;

    char notify[256];
    snprintf(notify, sizeof(notify),
        "notify-send --replace-id 9997 --app-name 'system' --icon display-brightness-symbolic --urgency low -h int:value:%d 'Brightness: %d%%'",
        percent, percent);
    system(notify);

    return 0;
}
