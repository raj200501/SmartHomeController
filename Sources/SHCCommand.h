#ifndef SHC_COMMAND_H
#define SHC_COMMAND_H

#include "SHCTypes.h"

typedef enum {
    SHC_COMMAND_STATUS,
    SHC_COMMAND_DASHBOARD,
    SHC_COMMAND_LIGHT_POWER,
    SHC_COMMAND_LIGHT_BRIGHTNESS,
    SHC_COMMAND_THERMOSTAT_SET,
    SHC_COMMAND_CAMERA_STREAM,
    SHC_COMMAND_CAMERA_SNAPSHOT,
    SHC_COMMAND_SCENE_LIST,
    SHC_COMMAND_SCENE_SHOW,
    SHC_COMMAND_SCENE_RUN,
    SHC_COMMAND_HELP,
    SHC_COMMAND_INVALID
} SHCCommandType;

typedef struct {
    SHCCommandType type;
    char *identifier;
    bool bool_value;
    int int_value;
    double double_value;
    char *config_path;
    char *scenes_path;
    char *state_path;
    bool verbose;
    bool output_json;
} SHCCommand;

void shc_command_destroy(SHCCommand *command);

#endif
