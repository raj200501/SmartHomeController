#ifndef SHC_SCENE_ACTION_H
#define SHC_SCENE_ACTION_H

#include "SHCTypes.h"

typedef enum {
    SHC_SCENE_ACTION_LIGHT_POWER,
    SHC_SCENE_ACTION_LIGHT_BRIGHTNESS,
    SHC_SCENE_ACTION_THERMOSTAT_TARGET,
    SHC_SCENE_ACTION_CAMERA_STREAM
} SHCSceneActionType;

typedef struct {
    SHCSceneActionType type;
    char *device_id;
    bool bool_value;
    int int_value;
    double double_value;
} SHCSceneAction;

SHCSceneAction *shc_scene_action_create(SHCSceneActionType type,
                                        const char *device_id);
void shc_scene_action_destroy(SHCSceneAction *action);

#endif
