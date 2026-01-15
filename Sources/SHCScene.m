#include "SHCScene.h"

#include "SHCString.h"

#include <stdio.h>
#include <stdlib.h>

SHCScene *shc_scene_create(const char *name, const char *summary) {
    if (!name) {
        fprintf(stderr, "[shc] Scene missing name.\n");
        return NULL;
    }

    SHCScene *scene = calloc(1, sizeof(SHCScene));
    if (!scene) {
        fprintf(stderr, "[shc] Scene allocation failed.\n");
        exit(1);
    }

    scene->name = shc_strdup(name);
    scene->summary = summary ? shc_strdup(summary) : shc_strdup("(no summary)");
    shc_array_init(&scene->actions);
    return scene;
}

void shc_scene_destroy(SHCScene *scene) {
    if (!scene) {
        return;
    }

    free(scene->name);
    free(scene->summary);
    shc_array_destroy(&scene->actions, (void (*)(void *))shc_scene_action_destroy);
    free(scene);
}

void shc_scene_add_action(SHCScene *scene, SHCSceneAction *action) {
    if (!scene || !action) {
        return;
    }

    shc_array_append(&scene->actions, action);
}

static const char *shc_scene_action_label(SHCSceneActionType type) {
    switch (type) {
        case SHC_SCENE_ACTION_LIGHT_POWER:
            return "light power";
        case SHC_SCENE_ACTION_LIGHT_BRIGHTNESS:
            return "light brightness";
        case SHC_SCENE_ACTION_THERMOSTAT_TARGET:
            return "thermostat target";
        case SHC_SCENE_ACTION_CAMERA_STREAM:
            return "camera stream";
        default:
            return "unknown";
    }
}

void shc_scene_describe(const SHCScene *scene, SHCStringBuilder *builder) {
    if (!scene || !builder) {
        return;
    }

    shc_sb_appendf(builder, "Scene: %s\n", scene->name);
    shc_sb_appendf(builder, "Summary: %s\n", scene->summary);
    shc_sb_append(builder, "Actions:\n");
    for (size_t i = 0; i < scene->actions.count; i++) {
        SHCSceneAction *action = (SHCSceneAction *)scene->actions.items[i];
        if (!action) {
            continue;
        }
        shc_sb_appendf(builder, "  - %s on %s", shc_scene_action_label(action->type), action->device_id);
        switch (action->type) {
            case SHC_SCENE_ACTION_LIGHT_POWER:
            case SHC_SCENE_ACTION_CAMERA_STREAM:
                shc_sb_appendf(builder, " => %s", action->bool_value ? "on" : "off");
                break;
            case SHC_SCENE_ACTION_LIGHT_BRIGHTNESS:
                shc_sb_appendf(builder, " => %d%%", action->int_value);
                break;
            case SHC_SCENE_ACTION_THERMOSTAT_TARGET:
                shc_sb_appendf(builder, " => %.1f", action->double_value);
                break;
            default:
                break;
        }
        shc_sb_append(builder, "\n");
    }
}
