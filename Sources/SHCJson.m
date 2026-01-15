#include "SHCJson.h"

#include "SHCCamera.h"
#include "SHCLight.h"
#include "SHCString.h"
#include "SHCThermostat.h"

static void shc_json_escape(SHCStringBuilder *builder, const char *value) {
    if (!value) {
        shc_sb_append(builder, "\"\"");
        return;
    }

    shc_sb_append_char(builder, '"');
    for (const char *cursor = value; *cursor; cursor++) {
        if (*cursor == '"' || *cursor == '\\') {
            shc_sb_append_char(builder, '\\');
        }
        if (*cursor == '\n') {
            shc_sb_append(builder, "\\n");
        } else if (*cursor == '\r') {
            shc_sb_append(builder, "\\r");
        } else if (*cursor == '\t') {
            shc_sb_append(builder, "\\t");
        } else {
            shc_sb_append_char(builder, *cursor);
        }
    }
    shc_sb_append_char(builder, '"');
}

void shc_json_devices(const SHCArray *devices, SHCStringBuilder *builder) {
    if (!devices || !builder) {
        return;
    }

    shc_sb_append(builder, "{\"devices\":[");
    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (!device) {
            continue;
        }

        if (i > 0) {
            shc_sb_append(builder, ",");
        }

        shc_sb_append(builder, "{");
        shc_sb_append(builder, "\"id\":");
        shc_json_escape(builder, device->identifier);
        shc_sb_append(builder, ",\"name\":");
        shc_json_escape(builder, device->name);
        shc_sb_append(builder, ",\"location\":");
        shc_json_escape(builder, device->location);
        shc_sb_append(builder, ",\"type\":");
        shc_json_escape(builder, shc_device_type_label(device->type));
        shc_sb_append(builder, ",\"online\":");
        shc_sb_append(builder, device->isOnline ? "true" : "false");

        if (device->type == SHC_DEVICE_LIGHT) {
            SHCLight *light = (SHCLight *)device;
            shc_sb_append(builder, ",\"power\":");
            shc_sb_append(builder, light->isOn ? "true" : "false");
            shc_sb_append(builder, ",\"brightness\":");
            shc_sb_appendf(builder, "%d", light->brightness);
        } else if (device->type == SHC_DEVICE_THERMOSTAT) {
            SHCThermostat *thermostat = (SHCThermostat *)device;
            shc_sb_append(builder, ",\"current\":");
            shc_sb_appendf(builder, "%.1f", thermostat->currentTemperature);
            shc_sb_append(builder, ",\"target\":");
            shc_sb_appendf(builder, "%.1f", thermostat->targetTemperature);
            shc_sb_append(builder, ",\"units\":");
            char units[2] = { thermostat->units, '\0' };
            shc_json_escape(builder, units);
        } else if (device->type == SHC_DEVICE_CAMERA) {
            SHCCamera *camera = (SHCCamera *)device;
            shc_sb_append(builder, ",\"streaming\":");
            shc_sb_append(builder, camera->isStreaming ? "true" : "false");
            shc_sb_append(builder, ",\"last_snapshot\":");
            shc_sb_appendf(builder, "%d", camera->lastSnapshotId);
        }

        shc_sb_append(builder, "}");
    }
    shc_sb_append(builder, "]}");
}
