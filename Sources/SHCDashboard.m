#include "SHCDashboard.h"

#include "SHCCamera.h"
#include "SHCLight.h"
#include "SHCThermostat.h"

void shc_dashboard_build(const SHCArray *devices, SHCStringBuilder *builder) {
    if (!devices || !builder) {
        return;
    }

    size_t lights_on = 0;
    size_t lights_total = 0;
    size_t cameras_streaming = 0;
    size_t cameras_total = 0;
    size_t thermostats_total = 0;
    double avg_temp = 0.0;

    for (size_t i = 0; i < devices->count; i++) {
        SHCDevice *device = (SHCDevice *)devices->items[i];
        if (!device) {
            continue;
        }

        switch (device->type) {
            case SHC_DEVICE_LIGHT: {
                SHCLight *light = (SHCLight *)device;
                lights_total++;
                if (light->isOn) {
                    lights_on++;
                }
                break;
            }
            case SHC_DEVICE_CAMERA: {
                SHCCamera *camera = (SHCCamera *)device;
                cameras_total++;
                if (camera->isStreaming) {
                    cameras_streaming++;
                }
                break;
            }
            case SHC_DEVICE_THERMOSTAT: {
                SHCThermostat *thermostat = (SHCThermostat *)device;
                thermostats_total++;
                avg_temp += thermostat->currentTemperature;
                break;
            }
            default:
                break;
        }
    }

    if (thermostats_total > 0) {
        avg_temp /= (double)thermostats_total;
    }

    shc_sb_append(builder, "Smart Home Dashboard\n");
    shc_sb_append(builder, "====================\n");
    shc_sb_appendf(builder, "Lights: %zu/%zu on\n", lights_on, lights_total);
    shc_sb_appendf(builder, "Cameras: %zu/%zu streaming\n", cameras_streaming, cameras_total);
    if (thermostats_total > 0) {
        SHCThermostat *first = NULL;
        for (size_t i = 0; i < devices->count; i++) {
            SHCDevice *device = (SHCDevice *)devices->items[i];
            if (device && device->type == SHC_DEVICE_THERMOSTAT) {
                first = (SHCThermostat *)device;
                break;
            }
        }
        char units = first ? first->units : 'C';
        shc_sb_appendf(builder, "Thermostats: %zu average %.1f%c\n",
                      thermostats_total,
                      avg_temp,
                      units);
    } else {
        shc_sb_append(builder, "Thermostats: none configured\n");
    }
}
