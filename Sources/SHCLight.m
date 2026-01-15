#include "SHCLight.h"

#include "SHCString.h"

#include <stdio.h>
#include <stdlib.h>

static int shc_light_normalize_brightness(int brightness) {
    if (brightness < 0) {
        return 0;
    }
    if (brightness > 100) {
        return 100;
    }
    return brightness;
}

SHCLight *shc_light_create(const char *identifier,
                           const char *name,
                           const char *location,
                           int brightness) {
    SHCLight *light = calloc(1, sizeof(SHCLight));
    if (!light) {
        fprintf(stderr, "[shc] light allocation failed.\n");
        exit(1);
    }

    SHCDevice *base = shc_device_create(identifier, name, location, SHC_DEVICE_LIGHT);
    if (!base) {
        free(light);
        return NULL;
    }

    light->base = *base;
    free(base);

    light->isOn = brightness > 0;
    light->brightness = shc_light_normalize_brightness(brightness);

    return light;
}

void shc_light_destroy(SHCLight *light) {
    if (!light) {
        return;
    }

    shc_device_cleanup(&light->base);
    free(light);
}

void shc_light_set_on(SHCLight *light, bool is_on) {
    if (!light) {
        return;
    }

    light->isOn = is_on;
    if (!is_on) {
        light->brightness = 0;
    } else if (light->brightness == 0) {
        light->brightness = 50;
    }
}

void shc_light_set_brightness(SHCLight *light, int brightness) {
    if (!light) {
        return;
    }

    light->brightness = shc_light_normalize_brightness(brightness);
    light->isOn = light->brightness > 0;
}

void shc_light_describe(const SHCLight *light, SHCStringBuilder *builder) {
    if (!light || !builder) {
        return;
    }

    shc_device_describe(&light->base, builder);
    shc_sb_appendf(builder, " | power=%s brightness=%d%%",
                  light->isOn ? "on" : "off",
                  light->brightness);
}
