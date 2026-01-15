#include "SHCConfig.h"

#include "SHCAttributes.h"
#include "SHCCamera.h"
#include "SHCLight.h"
#include "SHCString.h"
#include "SHCLogger.h"
#include "SHCThermostat.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void shc_config_add_device(SHCArray *devices, SHCDevice *device) {
    if (!device) {
        return;
    }
    shc_array_append(devices, device);
}

SHCArray shc_config_load_devices(const char *path) {
    SHCArray devices;
    shc_array_init(&devices);

    if (!path) {
        shc_log(SHC_LOG_ERROR, "Config path missing.");
        return devices;
    }

    FILE *file = fopen(path, "r");
    if (!file) {
        shc_log(SHC_LOG_ERROR, "Failed to open config file: %s", path);
        return devices;
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
        char **parts = shc_split(trimmed, ',', &part_count);
        if (part_count < 4) {
            shc_log(SHC_LOG_WARN, "Invalid config line %zu: %s", line_number, trimmed);
            shc_split_free(parts, part_count);
            free(trimmed);
            continue;
        }

        char *type = shc_strtrim(parts[0]);
        char *identifier = shc_strtrim(parts[1]);
        char *name = shc_strtrim(parts[2]);
        char *location = shc_strtrim(parts[3]);
        const char *attributes = part_count > 4 ? parts[4] : "";

        if (strcmp(type, "light") == 0) {
            char *brightness_value = shc_attributes_value(attributes, "brightness");
            int brightness = brightness_value ? atoi(brightness_value) : 75;
            free(brightness_value);
            SHCLight *light = shc_light_create(identifier, name, location, brightness);
            shc_config_add_device(&devices, (SHCDevice *)light);
        } else if (strcmp(type, "thermostat") == 0) {
            char *current_value = shc_attributes_value(attributes, "current");
            char *target_value = shc_attributes_value(attributes, "target");
            char *units_value = shc_attributes_value(attributes, "units");
            double current = current_value ? atof(current_value) : 21.0;
            double target = target_value ? atof(target_value) : 22.0;
            char units = units_value ? units_value[0] : 'C';
            SHCThermostat *thermostat = shc_thermostat_create(identifier, name, location, current, target, units);
            shc_config_add_device(&devices, (SHCDevice *)thermostat);
            free(current_value);
            free(target_value);
            free(units_value);
        } else if (strcmp(type, "camera") == 0) {
            char *stream_value = shc_attributes_value(attributes, "streaming");
            bool streaming = stream_value && (strcmp(stream_value, "on") == 0 || strcmp(stream_value, "true") == 0);
            SHCCamera *camera = shc_camera_create(identifier, name, location, streaming);
            shc_config_add_device(&devices, (SHCDevice *)camera);
            free(stream_value);
        } else {
            shc_log(SHC_LOG_WARN, "Unknown device type '%s' on line %zu", type, line_number);
        }

        free(type);
        free(identifier);
        free(name);
        free(location);
        shc_split_free(parts, part_count);
        free(trimmed);
    }

    fclose(file);
    return devices;
}
