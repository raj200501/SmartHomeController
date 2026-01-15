#include "SHCThermostat.h"

#include <stdio.h>
#include <stdlib.h>

static double shc_thermostat_clamp(const SHCThermostat *thermostat, double value) {
    if (value < thermostat->minTemperature) {
        return thermostat->minTemperature;
    }
    if (value > thermostat->maxTemperature) {
        return thermostat->maxTemperature;
    }
    return value;
}

SHCThermostat *shc_thermostat_create(const char *identifier,
                                     const char *name,
                                     const char *location,
                                     double current_temperature,
                                     double target_temperature,
                                     char units) {
    SHCThermostat *thermostat = calloc(1, sizeof(SHCThermostat));
    if (!thermostat) {
        fprintf(stderr, "[shc] thermostat allocation failed.\n");
        exit(1);
    }

    SHCDevice *base = shc_device_create(identifier, name, location, SHC_DEVICE_THERMOSTAT);
    if (!base) {
        free(thermostat);
        return NULL;
    }

    thermostat->base = *base;
    free(base);

    thermostat->units = units == 'F' ? 'F' : 'C';
    thermostat->minTemperature = thermostat->units == 'F' ? 60.0 : 16.0;
    thermostat->maxTemperature = thermostat->units == 'F' ? 85.0 : 29.5;

    thermostat->currentTemperature = shc_thermostat_clamp(thermostat, current_temperature);
    thermostat->targetTemperature = shc_thermostat_clamp(thermostat, target_temperature);

    return thermostat;
}

void shc_thermostat_destroy(SHCThermostat *thermostat) {
    if (!thermostat) {
        return;
    }

    shc_device_cleanup(&thermostat->base);
    free(thermostat);
}

void shc_thermostat_set_target(SHCThermostat *thermostat, double target) {
    if (!thermostat) {
        return;
    }

    thermostat->targetTemperature = shc_thermostat_clamp(thermostat, target);
}

void shc_thermostat_describe(const SHCThermostat *thermostat, SHCStringBuilder *builder) {
    if (!thermostat || !builder) {
        return;
    }

    shc_device_describe(&thermostat->base, builder);
    shc_sb_appendf(builder,
                  " | current=%.1f%c target=%.1f%c range=%.1f-%.1f%c",
                  thermostat->currentTemperature,
                  thermostat->units,
                  thermostat->targetTemperature,
                  thermostat->units,
                  thermostat->minTemperature,
                  thermostat->maxTemperature,
                  thermostat->units);
}
