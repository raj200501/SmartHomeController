#include "SHCDevice.h"

#include "SHCString.h"

#include <stdio.h>
#include <stdlib.h>

const char *shc_device_type_label(SHCDeviceType type) {
    switch (type) {
        case SHC_DEVICE_LIGHT:
            return "light";
        case SHC_DEVICE_THERMOSTAT:
            return "thermostat";
        case SHC_DEVICE_CAMERA:
            return "camera";
        default:
            return "unknown";
    }
}

SHCDevice *shc_device_create(const char *identifier,
                             const char *name,
                             const char *location,
                             SHCDeviceType type) {
    if (!identifier || !name || !location) {
        fprintf(stderr, "[shc] device creation failed: missing fields.\n");
        return NULL;
    }

    SHCDevice *device = calloc(1, sizeof(SHCDevice));
    if (!device) {
        fprintf(stderr, "[shc] device allocation failed.\n");
        exit(1);
    }

    device->identifier = shc_strdup(identifier);
    device->name = shc_strdup(name);
    device->location = shc_strdup(location);
    device->type = type;
    device->isOnline = true;

    return device;
}

void shc_device_cleanup(SHCDevice *device) {
    if (!device) {
        return;
    }

    free(device->identifier);
    free(device->name);
    free(device->location);
    device->identifier = NULL;
    device->name = NULL;
    device->location = NULL;
}

void shc_device_destroy(SHCDevice *device) {
    if (!device) {
        return;
    }

    shc_device_cleanup(device);
    free(device);
}

void shc_device_describe(const SHCDevice *device, SHCStringBuilder *builder) {
    if (!device || !builder) {
        return;
    }

    shc_sb_appendf(builder, "%s (%s) in %s [online=%s]",
                  device->name,
                  device->identifier,
                  device->location,
                  device->isOnline ? "yes" : "no");
}
