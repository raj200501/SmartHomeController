#include "SHCStore.h"

#include "SHCCamera.h"
#include "SHCLight.h"
#include "SHCString.h"
#include "SHCLogger.h"
#include "SHCThermostat.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static SHCDevice *shc_store_find_device(SHCArray *devices, const char *identifier) {
    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (device && strcmp(device->identifier, identifier) == 0) {
            return device;
        }
    }
    return NULL;
}

static void shc_store_apply_pair(SHCDevice *device, const char *key, const char *value) {
    if (!device || !key || !value) {
        return;
    }

    if (device->type == SHC_DEVICE_LIGHT) {
        SHCLight *light = (SHCLight *)device;
        if (strcmp(key, "power") == 0) {
            shc_light_set_on(light, strcmp(value, "on") == 0 || strcmp(value, "true") == 0);
        } else if (strcmp(key, "brightness") == 0) {
            shc_light_set_brightness(light, atoi(value));
        }
    } else if (device->type == SHC_DEVICE_THERMOSTAT) {
        SHCThermostat *thermostat = (SHCThermostat *)device;
        if (strcmp(key, "target") == 0) {
            shc_thermostat_set_target(thermostat, atof(value));
        } else if (strcmp(key, "current") == 0) {
            thermostat->currentTemperature = atof(value);
        }
    } else if (device->type == SHC_DEVICE_CAMERA) {
        SHCCamera *camera = (SHCCamera *)device;
        if (strcmp(key, "streaming") == 0) {
            shc_camera_set_streaming(camera, strcmp(value, "on") == 0 || strcmp(value, "true") == 0);
        } else if (strcmp(key, "last_snapshot") == 0) {
            camera->lastSnapshotId = atoi(value);
        }
    }
}

bool shc_store_load(const char *path, SHCArray *devices) {
    if (!path || !devices) {
        return false;
    }

    FILE *file = fopen(path, "r");
    if (!file) {
        shc_log(SHC_LOG_WARN, "State file not found, starting fresh: %s", path);
        return false;
    }

    char line[512];
    size_t line_number = 0;
    while (fgets(line, sizeof(line), file)) {
        line_number++;
        char *trimmed = shc_strtrim(line);
        if (trimmed[0] == '\0' || trimmed[0] == '#') {
            free(trimmed);
            continue;
        }

        size_t part_count = 0;
        char **parts = shc_split(trimmed, ' ', &part_count);
        if (part_count < 2) {
            shc_log(SHC_LOG_WARN, "Invalid state line %zu: %s", line_number, trimmed);
            shc_split_free(parts, part_count);
            free(trimmed);
            continue;
        }

        char *identifier = parts[0];
        SHCDevice *device = shc_store_find_device(devices, identifier);
        if (!device) {
            shc_log(SHC_LOG_WARN, "State line %zu references unknown device %s", line_number, identifier);
            shc_split_free(parts, part_count);
            free(trimmed);
            continue;
        }

        for (size_t i = 1; i < part_count; i++) {
            size_t pair_count = 0;
            char **pair = shc_split(parts[i], '=', &pair_count);
            if (pair_count == 2) {
                char *key = shc_strtrim(pair[0]);
                char *value = shc_strtrim(pair[1]);
                shc_store_apply_pair(device, key, value);
                free(key);
                free(value);
            }
            shc_split_free(pair, pair_count);
        }

        shc_split_free(parts, part_count);
        free(trimmed);
    }

    fclose(file);
    return true;
}

bool shc_store_save(const char *path, const SHCArray *devices) {
    if (!path || !devices) {
        return false;
    }

    FILE *file = fopen(path, "w");
    if (!file) {
        shc_log(SHC_LOG_ERROR, "Failed to write state file: %s", path);
        return false;
    }

    fprintf(file, "# Smart Home Controller state file\n");
    fprintf(file, "# Auto-generated, edit with caution\n\n");

    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (!device) {
            continue;
        }

        if (device->type == SHC_DEVICE_LIGHT) {
            SHCLight *light = (SHCLight *)device;
            fprintf(file, "%s power=%s brightness=%d\n",
                    device->identifier,
                    light->isOn ? "on" : "off",
                    light->brightness);
        } else if (device->type == SHC_DEVICE_THERMOSTAT) {
            SHCThermostat *thermostat = (SHCThermostat *)device;
            fprintf(file, "%s current=%.1f target=%.1f units=%c\n",
                    device->identifier,
                    thermostat->currentTemperature,
                    thermostat->targetTemperature,
                    thermostat->units);
        } else if (device->type == SHC_DEVICE_CAMERA) {
            SHCCamera *camera = (SHCCamera *)device;
            fprintf(file, "%s streaming=%s last_snapshot=%d\n",
                    device->identifier,
                    camera->isStreaming ? "on" : "off",
                    camera->lastSnapshotId);
        }
    }

    fclose(file);
    return true;
}
