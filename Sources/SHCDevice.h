#ifndef SHC_DEVICE_H
#define SHC_DEVICE_H

#include "SHCStringBuilder.h"
#include "SHCTypes.h"

typedef enum {
    SHC_DEVICE_LIGHT,
    SHC_DEVICE_THERMOSTAT,
    SHC_DEVICE_CAMERA,
    SHC_DEVICE_UNKNOWN
} SHCDeviceType;

typedef struct {
    char *identifier;
    char *name;
    char *location;
    SHCDeviceType type;
    bool isOnline;
} SHCDevice;

const char *shc_device_type_label(SHCDeviceType type);
SHCDevice *shc_device_create(const char *identifier,
                             const char *name,
                             const char *location,
                             SHCDeviceType type);
void shc_device_cleanup(SHCDevice *device);
void shc_device_destroy(SHCDevice *device);
void shc_device_describe(const SHCDevice *device, SHCStringBuilder *builder);

#endif
