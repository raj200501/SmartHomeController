#include "SHCSceneAction.h"

#include "SHCString.h"

#include <stdio.h>
#include <stdlib.h>

SHCSceneAction *shc_scene_action_create(SHCSceneActionType type,
                                        const char *device_id) {
    if (!device_id) {
        fprintf(stderr, "[shc] Scene action missing device id.\n");
        return NULL;
    }

    SHCSceneAction *action = calloc(1, sizeof(SHCSceneAction));
    if (!action) {
        fprintf(stderr, "[shc] Scene action allocation failed.\n");
        exit(1);
    }

    action->type = type;
    action->device_id = shc_strdup(device_id);
    return action;
}

void shc_scene_action_destroy(SHCSceneAction *action) {
    if (!action) {
        return;
    }

    free(action->device_id);
    free(action);
}
