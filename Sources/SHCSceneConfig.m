#include "SHCSceneConfig.h"

#include "SHCAttributes.h"
#include "SHCString.h"
#include "SHCLogger.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void shc_scene_config_add_scene(SHCArray *scenes, SHCScene *scene) {
    if (!scene) {
        return;
    }
    shc_array_append(scenes, scene);
}

static SHCSceneAction *shc_scene_parse_action(const char *type,
                                              const char *identifier,
                                              const char *attributes,
                                              size_t line_number) {
    if (!type || !identifier) {
        return NULL;
    }

    if (strcmp(type, "light") == 0) {
        char *power = shc_attributes_value(attributes, "power");
        char *brightness = shc_attributes_value(attributes, "brightness");
        SHCSceneAction *action = NULL;
        if (power) {
            action = shc_scene_action_create(SHC_SCENE_ACTION_LIGHT_POWER, identifier);
            action->bool_value = strcmp(power, "on") == 0 || strcmp(power, "true") == 0;
        } else if (brightness) {
            action = shc_scene_action_create(SHC_SCENE_ACTION_LIGHT_BRIGHTNESS, identifier);
            action->int_value = atoi(brightness);
        }
        free(power);
        free(brightness);
        if (!action) {
            shc_log(SHC_LOG_WARN, "Scene line %zu missing light action", line_number);
        }
        return action;
    }

    if (strcmp(type, "thermostat") == 0) {
        char *target = shc_attributes_value(attributes, "target");
        if (!target) {
            shc_log(SHC_LOG_WARN, "Scene line %zu missing thermostat target", line_number);
            return NULL;
        }
        SHCSceneAction *action = shc_scene_action_create(SHC_SCENE_ACTION_THERMOSTAT_TARGET, identifier);
        action->double_value = atof(target);
        free(target);
        return action;
    }

    if (strcmp(type, "camera") == 0) {
        char *streaming = shc_attributes_value(attributes, "streaming");
        if (!streaming) {
            shc_log(SHC_LOG_WARN, "Scene line %zu missing camera streaming state", line_number);
            return NULL;
        }
        SHCSceneAction *action = shc_scene_action_create(SHC_SCENE_ACTION_CAMERA_STREAM, identifier);
        action->bool_value = strcmp(streaming, "on") == 0 || strcmp(streaming, "true") == 0;
        free(streaming);
        return action;
    }

    shc_log(SHC_LOG_WARN, "Unknown scene action type '%s' on line %zu", type, line_number);
    return NULL;
}

SHCArray shc_scene_config_load(const char *path) {
    SHCArray scenes;
    shc_array_init(&scenes);

    if (!path) {
        shc_log(SHC_LOG_ERROR, "Scene config path missing.");
        return scenes;
    }

    FILE *file = fopen(path, "r");
    if (!file) {
        shc_log(SHC_LOG_ERROR, "Failed to open scene config: %s", path);
        return scenes;
    }

    SHCScene *current_scene = NULL;
    char line[512];
    size_t line_number = 0;
    while (fgets(line, sizeof(line), file)) {
        line_number++;
        char *trimmed = shc_strtrim(line);
        if (trimmed[0] == '\0' || trimmed[0] == '#') {
            free(trimmed);
            continue;
        }

        if (shc_starts_with(trimmed, "scene")) {
            size_t part_count = 0;
            char **parts = shc_split(trimmed, ',', &part_count);
            if (part_count < 2) {
                shc_log(SHC_LOG_WARN, "Invalid scene header on line %zu", line_number);
                shc_split_free(parts, part_count);
                free(trimmed);
                continue;
            }

            char *name = shc_strtrim(parts[1]);
            char *summary = NULL;
            if (part_count > 2) {
                summary = shc_strtrim(parts[2]);
            }

            if (current_scene) {
                shc_scene_config_add_scene(&scenes, current_scene);
            }

            current_scene = shc_scene_create(name, summary);
            free(name);
            free(summary);
            shc_split_free(parts, part_count);
            free(trimmed);
            continue;
        }

        if (strcmp(trimmed, "end") == 0) {
            if (current_scene) {
                shc_scene_config_add_scene(&scenes, current_scene);
                current_scene = NULL;
            }
            free(trimmed);
            continue;
        }

        if (!current_scene) {
            shc_log(SHC_LOG_WARN, "Scene action outside of scene block on line %zu", line_number);
            free(trimmed);
            continue;
        }

        size_t part_count = 0;
        char **parts = shc_split(trimmed, ',', &part_count);
        if (part_count < 3) {
            shc_log(SHC_LOG_WARN, "Invalid scene action on line %zu", line_number);
            shc_split_free(parts, part_count);
            free(trimmed);
            continue;
        }

        char *type = shc_strtrim(parts[0]);
        char *identifier = shc_strtrim(parts[1]);
        const char *attributes = parts[2];

        SHCSceneAction *action = shc_scene_parse_action(type, identifier, attributes, line_number);
        if (action) {
            shc_scene_add_action(current_scene, action);
        }

        free(type);
        free(identifier);
        shc_split_free(parts, part_count);
        free(trimmed);
    }

    if (current_scene) {
        shc_scene_config_add_scene(&scenes, current_scene);
    }

    fclose(file);
    return scenes;
}

SHCScene *shc_scene_config_find(SHCArray *scenes, const char *name) {
    if (!scenes || !name) {
        return NULL;
    }

    for (size_t i = 0; i < scenes->count; i++) {
        SHCScene *scene = (SHCScene *)scenes->items[i];
        if (scene && strcmp(scene->name, name) == 0) {
            return scene;
        }
    }

    return NULL;
}
