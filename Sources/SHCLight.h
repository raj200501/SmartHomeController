#ifndef SHC_LIGHT_H
#define SHC_LIGHT_H

#include "SHCDevice.h"

typedef struct {
    SHCDevice base;
    bool isOn;
    int brightness;
} SHCLight;

SHCLight *shc_light_create(const char *identifier,
                           const char *name,
                           const char *location,
                           int brightness);
void shc_light_destroy(SHCLight *light);
void shc_light_set_on(SHCLight *light, bool is_on);
void shc_light_set_brightness(SHCLight *light, int brightness);
void shc_light_describe(const SHCLight *light, SHCStringBuilder *builder);

#endif
