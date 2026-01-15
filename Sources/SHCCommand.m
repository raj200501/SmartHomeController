#include "SHCCommand.h"

#include <stdlib.h>

void shc_command_destroy(SHCCommand *command) {
    if (!command) {
        return;
    }

    free(command->identifier);
    free(command->config_path);
    free(command->scenes_path);
    free(command->state_path);
    free(command);
}
