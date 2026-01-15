#include "SHCSceneRunner.h"

#include "SHCController.h"
#include "SHCLogger.h"

static void shc_scene_append_result(SHCStringBuilder *builder,
                                    const char *device_id,
                                    const char *action,
                                    bool success) {
    if (!builder) {
        return;
    }

    shc_sb_appendf(builder, "%s: %s => %s\n", device_id, action, success ? "ok" : "failed");
}

bool shc_scene_apply(const SHCScene *scene, SHCArray *devices, SHCStringBuilder *builder) {
    if (!scene || !devices) {
        return false;
    }

    bool success = true;
    for (size_t i = 0; i < scene->actions.count; i++) {
        SHCSceneAction *action = (SHCSceneAction *)scene->actions.items[i];
        if (!action) {
            continue;
        }

        bool action_result = false;
        switch (action->type) {
            case SHC_SCENE_ACTION_LIGHT_POWER:
                action_result = shc_controller_set_light(devices, action->device_id, action->bool_value);
                shc_scene_append_result(builder, action->device_id,
                                        action->bool_value ? "light power on" : "light power off",
                                        action_result);
                break;
            case SHC_SCENE_ACTION_LIGHT_BRIGHTNESS:
                action_result = shc_controller_set_brightness(devices, action->device_id, action->int_value);
                shc_scene_append_result(builder, action->device_id, "light brightness", action_result);
                break;
            case SHC_SCENE_ACTION_THERMOSTAT_TARGET:
                action_result = shc_controller_set_thermostat(devices, action->device_id, action->double_value);
                shc_scene_append_result(builder, action->device_id, "thermostat target", action_result);
                break;
            case SHC_SCENE_ACTION_CAMERA_STREAM:
                action_result = shc_controller_set_camera_stream(devices, action->device_id, action->bool_value);
                shc_scene_append_result(builder, action->device_id,
                                        action->bool_value ? "camera stream on" : "camera stream off",
                                        action_result);
                break;
            default:
                shc_log(SHC_LOG_WARN, "Unknown action type for device %s", action->device_id);
                action_result = false;
                break;
        }

        if (!action_result) {
            success = false;
        }
    }

    return success;
}
