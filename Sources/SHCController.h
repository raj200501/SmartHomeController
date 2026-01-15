#ifndef SHC_CONTROLLER_H
#define SHC_CONTROLLER_H

#include "SHCArray.h"
#include "SHCDevice.h"
#include "SHCStringBuilder.h"

SHCArray shc_controller_init_devices(const char *config_path, const char *state_path);
void shc_controller_destroy_devices(SHCArray *devices);
SHCDevice *shc_controller_find(SHCArray *devices, const char *identifier);
void shc_controller_list(const SHCArray *devices, SHCStringBuilder *builder);
bool shc_controller_set_light(SHCArray *devices, const char *identifier, bool on);
bool shc_controller_set_brightness(SHCArray *devices, const char *identifier, int brightness);
bool shc_controller_set_thermostat(SHCArray *devices, const char *identifier, double target);
bool shc_controller_set_camera_stream(SHCArray *devices, const char *identifier, bool on);
bool shc_controller_take_snapshot(SHCArray *devices, const char *identifier, int *snapshot_id);
bool shc_controller_save_state(const SHCArray *devices, const char *state_path);

#endif
