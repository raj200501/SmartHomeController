#include "SHCCommandParser.h"
#include "SHCController.h"
#include "SHCDashboard.h"
#include "SHCJson.h"
#include "SHCLogger.h"
#include "SHCSceneConfig.h"
#include "SHCSceneRunner.h"
#include "SHCString.h"
#include "SHCStringBuilder.h"
#include "SHCStore.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *shc_env_or_default(const char *key, const char *fallback) {
    const char *value = getenv(key);
    if (value && value[0] != '\0') {
        return value;
    }
    return fallback;
}

static const char *shc_default_config_path(void) {
    return shc_env_or_default("SHC_CONFIG", "config/devices.conf");
}

static const char *shc_default_state_path(void) {
    return shc_env_or_default("SHC_STATE", "data/state.db");
}

static const char *shc_default_scenes_path(void) {
    return shc_env_or_default("SHC_SCENES", "config/scenes.conf");
}

static void shc_apply_log_level(void) {
    const char *level = getenv("SHC_LOG_LEVEL");
    if (!level) {
        return;
    }

    if (strcmp(level, "debug") == 0) {
        shc_logger_set_level(SHC_LOG_DEBUG);
    } else if (strcmp(level, "info") == 0) {
        shc_logger_set_level(SHC_LOG_INFO);
    } else if (strcmp(level, "warn") == 0) {
        shc_logger_set_level(SHC_LOG_WARN);
    } else if (strcmp(level, "error") == 0) {
        shc_logger_set_level(SHC_LOG_ERROR);
    }
}

static void shc_print_status(const SHCArray *devices, bool json) {
    SHCStringBuilder builder;
    shc_sb_init(&builder);
    if (json) {
        shc_json_devices(devices, &builder);
    } else {
        shc_controller_list(devices, &builder);
    }

    char *output = shc_sb_build(&builder);
    printf("%s", output);
    if (!json) {
        printf("\n");
    }
    free(output);
}

static void shc_print_dashboard(const SHCArray *devices) {
    SHCStringBuilder builder;
    shc_sb_init(&builder);
    shc_dashboard_build(devices, &builder);
    char *output = shc_sb_build(&builder);
    printf("%s", output);
    free(output);
}

static int shc_handle_command(SHCCommand *command, SHCArray *devices, const char *state_path) {
    if (!command || !devices) {
        return 1;
    }

    switch (command->type) {
        case SHC_COMMAND_STATUS:
            shc_print_status(devices, command->output_json);
            return 0;
        case SHC_COMMAND_DASHBOARD:
            shc_print_dashboard(devices);
            return 0;
        case SHC_COMMAND_SCENE_LIST:
        case SHC_COMMAND_SCENE_SHOW:
        case SHC_COMMAND_SCENE_RUN:
            fprintf(stderr, "Scene command requires scene config.\n");
            return 1;
        case SHC_COMMAND_LIGHT_POWER: {
            if (!command->identifier) {
                fprintf(stderr, "Missing light identifier.\n");
                return 1;
            }
            if (!shc_controller_set_light(devices, command->identifier, command->bool_value)) {
                fprintf(stderr, "Light not found: %s\n", command->identifier);
                return 1;
            }
            printf("Light %s turned %s.\n", command->identifier, command->bool_value ? "on" : "off");
            break;
        }
        case SHC_COMMAND_LIGHT_BRIGHTNESS: {
            if (!command->identifier) {
                fprintf(stderr, "Missing light identifier.\n");
                return 1;
            }
            if (!shc_controller_set_brightness(devices, command->identifier, command->int_value)) {
                fprintf(stderr, "Light not found: %s\n", command->identifier);
                return 1;
            }
            printf("Light %s brightness set to %d%%.\n", command->identifier, command->int_value);
            break;
        }
        case SHC_COMMAND_THERMOSTAT_SET: {
            if (!command->identifier) {
                fprintf(stderr, "Missing thermostat identifier.\n");
                return 1;
            }
            if (!shc_controller_set_thermostat(devices, command->identifier, command->double_value)) {
                fprintf(stderr, "Thermostat not found: %s\n", command->identifier);
                return 1;
            }
            printf("Thermostat %s target set to %.1f.\n", command->identifier, command->double_value);
            break;
        }
        case SHC_COMMAND_CAMERA_STREAM: {
            if (!command->identifier) {
                fprintf(stderr, "Missing camera identifier.\n");
                return 1;
            }
            if (!shc_controller_set_camera_stream(devices, command->identifier, command->bool_value)) {
                fprintf(stderr, "Camera not found: %s\n", command->identifier);
                return 1;
            }
            printf("Camera %s streaming %s.\n", command->identifier, command->bool_value ? "on" : "off");
            break;
        }
        case SHC_COMMAND_CAMERA_SNAPSHOT: {
            if (!command->identifier) {
                fprintf(stderr, "Missing camera identifier.\n");
                return 1;
            }
            int snapshot_id = 0;
            if (!shc_controller_take_snapshot(devices, command->identifier, &snapshot_id)) {
                fprintf(stderr, "Camera not found: %s\n", command->identifier);
                return 1;
            }
            printf("Camera %s snapshot captured: %d\n", command->identifier, snapshot_id);
            break;
        }
        case SHC_COMMAND_HELP:
            shc_print_help("smart_home_controller");
            return 0;
        default:
            fprintf(stderr, "Unknown command. Use --help for usage.\n");
            return 1;
    }

    if (state_path) {
        if (!shc_controller_save_state(devices, state_path)) {
            fprintf(stderr, "Warning: failed to persist state to %s\n", state_path);
        }
    }

    return 0;
}

int main(int argc, char **argv) {
    shc_apply_log_level();

    SHCCommand *command = shc_parse_command(argc, argv);
    if (!command) {
        fprintf(stderr, "Failed to parse command.\n");
        return 1;
    }

    if (command->verbose) {
        shc_logger_set_level(SHC_LOG_DEBUG);
    }

    if (command->type == SHC_COMMAND_HELP) {
        shc_print_help(argv[0]);
        shc_command_destroy(command);
        return 0;
    }

    const char *config_path = command->config_path ? command->config_path : shc_default_config_path();
    const char *state_path = command->state_path ? command->state_path : shc_default_state_path();
    const char *scenes_path = command->scenes_path ? command->scenes_path : shc_default_scenes_path();

    SHCArray devices = shc_controller_init_devices(config_path, state_path);

    int result = 0;
    if (command->type == SHC_COMMAND_SCENE_LIST ||
        command->type == SHC_COMMAND_SCENE_SHOW ||
        command->type == SHC_COMMAND_SCENE_RUN) {
        SHCArray scenes = shc_scene_config_load(scenes_path);
        if (command->type == SHC_COMMAND_SCENE_LIST) {
            for (size_t i = 0; i < scenes.count; i++) {
                SHCScene *scene = (SHCScene *)scenes.items[i];
                if (scene) {
                    printf("%s - %s\n", scene->name, scene->summary);
                }
            }
        } else if (command->type == SHC_COMMAND_SCENE_SHOW) {
            if (!command->identifier) {
                fprintf(stderr, "Missing scene name.\n");
                result = 1;
            } else {
                SHCScene *scene = shc_scene_config_find(&scenes, command->identifier);
                if (!scene) {
                    fprintf(stderr, "Scene not found: %s\n", command->identifier);
                    result = 1;
                } else {
                    SHCStringBuilder builder;
                    shc_sb_init(&builder);
                    shc_scene_describe(scene, &builder);
                    char *output = shc_sb_build(&builder);
                    printf("%s", output);
                    free(output);
                }
            }
        } else if (command->type == SHC_COMMAND_SCENE_RUN) {
            if (!command->identifier) {
                fprintf(stderr, "Missing scene name.\n");
                result = 1;
            } else {
                SHCScene *scene = shc_scene_config_find(&scenes, command->identifier);
                if (!scene) {
                    fprintf(stderr, "Scene not found: %s\n", command->identifier);
                    result = 1;
                } else {
                    SHCStringBuilder builder;
                    shc_sb_init(&builder);
                    bool applied = shc_scene_apply(scene, &devices, &builder);
                    char *output = shc_sb_build(&builder);
                    printf("%s", output);
                    free(output);
                    result = applied ? 0 : 1;
                }
            }
        }

        for (size_t i = 0; i < scenes.count; i++) {
            shc_scene_destroy((SHCScene *)scenes.items[i]);
        }
        shc_array_destroy(&scenes, NULL);

        if (result == 0 && command->type == SHC_COMMAND_SCENE_RUN && state_path) {
            if (!shc_controller_save_state(&devices, state_path)) {
                fprintf(stderr, "Warning: failed to persist state to %s\n", state_path);
            }
        }
    } else {
        result = shc_handle_command(command, &devices, state_path);
    }

    shc_controller_destroy_devices(&devices);
    shc_command_destroy(command);

    return result;
}
