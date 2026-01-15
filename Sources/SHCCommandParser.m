#include "SHCCommandParser.h"

#include "SHCString.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static SHCCommand *shc_command_create(void) {
    SHCCommand *command = calloc(1, sizeof(SHCCommand));
    if (!command) {
        fprintf(stderr, "[shc] Failed to allocate command.\n");
        exit(1);
    }
    command->type = SHC_COMMAND_INVALID;
    return command;
}

static bool shc_matches(const char *value, const char *expected) {
    return value && expected && strcmp(value, expected) == 0;
}

static const char *shc_next_arg(int argc, char **argv, int *index) {
    if (*index + 1 >= argc) {
        return NULL;
    }
    *index += 1;
    return argv[*index];
}

static void shc_apply_global_flag(SHCCommand *command, const char *flag, int argc, char **argv, int *index) {
    if (shc_matches(flag, "--config")) {
        const char *value = shc_next_arg(argc, argv, index);
        if (value) {
            command->config_path = shc_strdup(value);
        }
    } else if (shc_matches(flag, "--scenes")) {
        const char *value = shc_next_arg(argc, argv, index);
        if (value) {
            command->scenes_path = shc_strdup(value);
        }
    } else if (shc_matches(flag, "--state")) {
        const char *value = shc_next_arg(argc, argv, index);
        if (value) {
            command->state_path = shc_strdup(value);
        }
    } else if (shc_matches(flag, "--verbose")) {
        command->verbose = true;
    } else if (shc_matches(flag, "--json")) {
        command->output_json = true;
    }
}

static void shc_set_identifier(SHCCommand *command, const char *value) {
    if (!command->identifier && value) {
        command->identifier = shc_strdup(value);
    }
}

SHCCommand *shc_parse_command(int argc, char **argv) {
    SHCCommand *command = shc_command_create();

    if (argc < 2) {
        command->type = SHC_COMMAND_HELP;
        return command;
    }

    for (int i = 1; i < argc; i++) {
        const char *arg = argv[i];
        if (shc_matches(arg, "--help") || shc_matches(arg, "-h")) {
            command->type = SHC_COMMAND_HELP;
            return command;
        }
        if (strncmp(arg, "--", 2) == 0) {
            shc_apply_global_flag(command, arg, argc, argv, &i);
            continue;
        }

        if (shc_matches(arg, "status")) {
            command->type = SHC_COMMAND_STATUS;
        } else if (shc_matches(arg, "dashboard")) {
            command->type = SHC_COMMAND_DASHBOARD;
        } else if (shc_matches(arg, "scene")) {
            const char *action = shc_next_arg(argc, argv, &i);
            if (action && shc_matches(action, "list")) {
                command->type = SHC_COMMAND_SCENE_LIST;
            } else if (action && shc_matches(action, "show")) {
                const char *name = shc_next_arg(argc, argv, &i);
                shc_set_identifier(command, name);
                command->type = SHC_COMMAND_SCENE_SHOW;
            } else if (action && shc_matches(action, "run")) {
                const char *name = shc_next_arg(argc, argv, &i);
                shc_set_identifier(command, name);
                command->type = SHC_COMMAND_SCENE_RUN;
            }
        } else if (shc_matches(arg, "light")) {
            const char *action = shc_next_arg(argc, argv, &i);
            const char *identifier = shc_next_arg(argc, argv, &i);
            shc_set_identifier(command, identifier);
            if (!action) {
                command->type = SHC_COMMAND_INVALID;
                return command;
            }
            if (shc_matches(action, "on")) {
                command->type = SHC_COMMAND_LIGHT_POWER;
                command->bool_value = true;
            } else if (shc_matches(action, "off")) {
                command->type = SHC_COMMAND_LIGHT_POWER;
                command->bool_value = false;
            } else if (shc_matches(action, "brightness")) {
                const char *value = shc_next_arg(argc, argv, &i);
                command->type = SHC_COMMAND_LIGHT_BRIGHTNESS;
                command->int_value = value ? atoi(value) : 0;
            }
        } else if (shc_matches(arg, "thermostat")) {
            const char *action = shc_next_arg(argc, argv, &i);
            const char *identifier = shc_next_arg(argc, argv, &i);
            const char *value = shc_next_arg(argc, argv, &i);
            shc_set_identifier(command, identifier);
            if (action && shc_matches(action, "set")) {
                command->type = SHC_COMMAND_THERMOSTAT_SET;
                command->double_value = value ? atof(value) : 0.0;
            }
        } else if (shc_matches(arg, "camera")) {
            const char *action = shc_next_arg(argc, argv, &i);
            const char *identifier = shc_next_arg(argc, argv, &i);
            shc_set_identifier(command, identifier);
            if (action && shc_matches(action, "stream")) {
                const char *value = shc_next_arg(argc, argv, &i);
                command->type = SHC_COMMAND_CAMERA_STREAM;
                command->bool_value = value && (strcmp(value, "on") == 0 || strcmp(value, "true") == 0);
            } else if (action && shc_matches(action, "snapshot")) {
                command->type = SHC_COMMAND_CAMERA_SNAPSHOT;
            }
        }
    }

    if (command->type == SHC_COMMAND_INVALID) {
        command->type = SHC_COMMAND_HELP;
    }

    return command;
}

void shc_print_help(const char *program) {
    const char *name = program ? program : "smart_home_controller";
    printf("Smart Home Controller CLI\n");
    printf("Usage:\n");
    printf("  %s status [--config path] [--state path] [--json]\n", name);
    printf("  %s dashboard [--config path] [--state path]\n", name);
    printf("  %s scene list [--scenes path]\n", name);
    printf("  %s scene show <name> [--scenes path]\n", name);
    printf("  %s scene run <name> [--scenes path] [--state path]\n", name);
    printf("  %s light on <id> [--config path] [--state path]\n", name);
    printf("  %s light off <id> [--config path] [--state path]\n", name);
    printf("  %s light brightness <id> <0-100> [--config path] [--state path]\n", name);
    printf("  %s thermostat set <id> <temp> [--config path] [--state path]\n", name);
    printf("  %s camera stream <id> <on|off> [--config path] [--state path]\n", name);
    printf("  %s camera snapshot <id> [--config path] [--state path]\n", name);
    printf("  %s --help\n", name);
}
