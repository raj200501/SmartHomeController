#ifndef SHC_THERMOSTAT_H
#define SHC_THERMOSTAT_H

#include "SHCDevice.h"

typedef struct {
    SHCDevice base;
    double currentTemperature;
    double targetTemperature;
    char units;
    double minTemperature;
    double maxTemperature;
} SHCThermostat;

SHCThermostat *shc_thermostat_create(const char *identifier,
                                     const char *name,
                                     const char *location,
                                     double current_temperature,
                                     double target_temperature,
                                     char units);
void shc_thermostat_destroy(SHCThermostat *thermostat);
void shc_thermostat_set_target(SHCThermostat *thermostat, double target);
void shc_thermostat_describe(const SHCThermostat *thermostat, SHCStringBuilder *builder);

#endif
