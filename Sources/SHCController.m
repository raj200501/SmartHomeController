#include "SHCController.h"

#include "SHCArray.h"
#include "SHCCamera.h"
#include "SHCConfig.h"
#include "SHCLight.h"
#include "SHCLogger.h"
#include "SHCStore.h"
#include "SHCThermostat.h"

#include <string.h>

SHCArray shc_controller_init_devices(const char *config_path, const char *state_path) {
    SHCArray devices = shc_config_load_devices(config_path);
    if (devices.count == 0) {
        shc_log(SHC_LOG_WARN, "No devices loaded from config: %s", config_path ? config_path : "(null)");
    }

    if (state_path) {
        shc_store_load(state_path, &devices);
    }

    return devices;
}

void shc_controller_destroy_devices(SHCArray *devices) {
    if (!devices) {
        return;
    }

    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (!device) {
            continue;
        }

        if (device->type == SHC_DEVICE_LIGHT) {
            shc_light_destroy((SHCLight *)device);
        } else if (device->type == SHC_DEVICE_THERMOSTAT) {
            shc_thermostat_destroy((SHCThermostat *)device);
        } else if (device->type == SHC_DEVICE_CAMERA) {
            shc_camera_destroy((SHCCamera *)device);
        } else {
            shc_device_destroy(device);
        }
    }

    shc_array_destroy(devices, NULL);
}

SHCDevice *shc_controller_find(SHCArray *devices, const char *identifier) {
    if (!devices || !identifier) {
        return NULL;
    }

    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (device && strcmp(device->identifier, identifier) == 0) {
            return device;
        }
    }

    return NULL;
}

void shc_controller_list(const SHCArray *devices, SHCStringBuilder *builder) {
    if (!devices || !builder) {
        return;
    }

    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (!device) {
            continue;
        }

        if (device->type == SHC_DEVICE_LIGHT) {
            shc_light_describe((SHCLight *)device, builder);
        } else if (device->type == SHC_DEVICE_THERMOSTAT) {
            shc_thermostat_describe((SHCThermostat *)device, builder);
        } else if (device->type == SHC_DEVICE_CAMERA) {
            shc_camera_describe((SHCCamera *)device, builder);
        } else {
            shc_device_describe(device, builder);
        }

        shc_sb_append(builder, "\n");
    }
}

bool shc_controller_set_light(SHCArray *devices, const char *identifier, bool on) {
    SHCDevice *device = shc_controller_find(devices, identifier);
    if (!device || device->type != SHC_DEVICE_LIGHT) {
        return false;
    }

    shc_light_set_on((SHCLight *)device, on);
    return true;
}

bool shc_controller_set_brightness(SHCArray *devices, const char *identifier, int brightness) {
    SHCDevice *device = shc_controller_find(devices, identifier);
    if (!device || device->type != SHC_DEVICE_LIGHT) {
        return false;
    }

    shc_light_set_brightness((SHCLight *)device, brightness);
    return true;
}

bool shc_controller_set_thermostat(SHCArray *devices, const char *identifier, double target) {
    SHCDevice *device = shc_controller_find(devices, identifier);
    if (!device || device->type != SHC_DEVICE_THERMOSTAT) {
        return false;
    }

    shc_thermostat_set_target((SHCThermostat *)device, target);
    return true;
}

bool shc_controller_set_camera_stream(SHCArray *devices, const char *identifier, bool on) {
    SHCDevice *device = shc_controller_find(devices, identifier);
    if (!device || device->type != SHC_DEVICE_CAMERA) {
        return false;
    }

    shc_camera_set_streaming((SHCCamera *)device, on);
    return true;
}

bool shc_controller_take_snapshot(SHCArray *devices, const char *identifier, int *snapshot_id) {
    SHCDevice *device = shc_controller_find(devices, identifier);
    if (!device || device->type != SHC_DEVICE_CAMERA) {
        return false;
    }

    int result = shc_camera_snapshot((SHCCamera *)device);
    if (snapshot_id) {
        *snapshot_id = result;
    }
    return result >= 0;
}

bool shc_controller_save_state(const SHCArray *devices, const char *state_path) {
    if (!devices || !state_path) {
        return false;
    }

    return shc_store_save(state_path, devices);
}
