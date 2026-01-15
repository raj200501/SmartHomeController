#include "SHCAttributes.h"
#include "SHCConfig.h"
#include "SHCController.h"
#include "SHCSceneConfig.h"
#include "SHCSceneRunner.h"
#include "SHCString.h"
#include "SHCStringBuilder.h"
#include "SHCStore.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SHC_TEST_ASSERT(condition, message) \
    do { \
        if (!(condition)) { \
            fprintf(stderr, "[TEST] Assertion failed: %s (%s:%d)\n", message, __FILE__, __LINE__); \
            return false; \
        } \
    } while (0)

static bool test_string_utilities(void) {
    char *trimmed = shc_strtrim("  hello world \n");
    SHC_TEST_ASSERT(strcmp(trimmed, "hello world") == 0, "trimmed string matches");
    free(trimmed);

    char *lower = shc_strtolower("HeLLo");
    SHC_TEST_ASSERT(strcmp(lower, "hello") == 0, "lowercase conversion");
    free(lower);

    SHC_TEST_ASSERT(shc_starts_with("scene", "sc"), "starts_with");
    SHC_TEST_ASSERT(shc_ends_with("scene", "ne"), "ends_with");

    char *replaced = shc_strreplace("lights-on", "-", " ");
    SHC_TEST_ASSERT(strcmp(replaced, "lights on") == 0, "replace string");
    free(replaced);

    char *value = shc_attributes_value("power=on,brightness=50", "brightness");
    SHC_TEST_ASSERT(value != NULL && strcmp(value, "50") == 0, "attribute value");
    free(value);

    return true;
}

static bool test_string_builder(void) {
    SHCStringBuilder builder;
    shc_sb_init(&builder);
    shc_sb_append(&builder, "hello");
    shc_sb_append_char(&builder, ' ');
    shc_sb_appendf(&builder, "%s", "world");
    char *result = shc_sb_build(&builder);
    SHC_TEST_ASSERT(strcmp(result, "hello world") == 0, "string builder output");
    free(result);
    return true;
}

static bool test_config_load(void) {
    SHCArray devices = shc_config_load_devices("tests/fixtures/devices.conf");
    SHC_TEST_ASSERT(devices.count == 4, "device count");

    SHCDevice *device = (SHCDevice *)devices.items[0];
    SHC_TEST_ASSERT(device != NULL, "device exists");
    SHC_TEST_ASSERT(strcmp(device->identifier, "test-light-1") == 0, "device id");

    shc_controller_destroy_devices(&devices);
    return true;
}

static bool test_scene_load(void) {
    SHCArray scenes = shc_scene_config_load("tests/fixtures/scenes.conf");
    SHC_TEST_ASSERT(scenes.count == 1, "scene count");

    SHCScene *scene = (SHCScene *)scenes.items[0];
    SHC_TEST_ASSERT(scene != NULL, "scene exists");
    SHC_TEST_ASSERT(scene->actions.count == 4, "scene action count");

    for (size_t i = 0; i < scenes.count; i++) {
        shc_scene_destroy((SHCScene *)scenes.items[i]);
    }
    shc_array_destroy(&scenes, NULL);
    return true;
}

static bool test_controller_actions(void) {
    SHCArray devices = shc_config_load_devices("tests/fixtures/devices.conf");
    SHC_TEST_ASSERT(shc_controller_set_light(&devices, "test-light-2", true), "light power set");
    SHC_TEST_ASSERT(shc_controller_set_brightness(&devices, "test-light-2", 80), "brightness set");
    SHC_TEST_ASSERT(shc_controller_set_thermostat(&devices, "test-thermo", 23.0), "thermostat set");
    SHC_TEST_ASSERT(shc_controller_set_camera_stream(&devices, "test-cam", true), "camera streaming set");

    SHCDevice *device = shc_controller_find(&devices, "test-light-2");
    SHC_TEST_ASSERT(device != NULL, "device found");

    shc_controller_destroy_devices(&devices);
    return true;
}

static bool test_scene_apply(void) {
    SHCArray devices = shc_config_load_devices("tests/fixtures/devices.conf");
    SHCArray scenes = shc_scene_config_load("tests/fixtures/scenes.conf");
    SHCScene *scene = shc_scene_config_find(&scenes, "test-scene");
    SHC_TEST_ASSERT(scene != NULL, "scene loaded");

    SHCStringBuilder builder;
    shc_sb_init(&builder);
    bool applied = shc_scene_apply(scene, &devices, &builder);
    char *output = shc_sb_build(&builder);
    SHC_TEST_ASSERT(applied, "scene applied");
    SHC_TEST_ASSERT(strstr(output, "test-light-1") != NULL, "scene output contains light");
    free(output);

    for (size_t i = 0; i < scenes.count; i++) {
        shc_scene_destroy((SHCScene *)scenes.items[i]);
    }
    shc_array_destroy(&scenes, NULL);
    shc_controller_destroy_devices(&devices);
    return true;
}

static bool test_store_roundtrip(void) {
    SHCArray devices = shc_config_load_devices("tests/fixtures/devices.conf");
    shc_controller_set_light(&devices, "test-light-1", false);
    shc_controller_set_brightness(&devices, "test-light-1", 10);
    shc_controller_set_thermostat(&devices, "test-thermo", 19.0);

    char template_path[128];
    snprintf(template_path, sizeof(template_path), "/tmp/shc_state_%d.db", getpid());
    FILE *tmp_file = fopen(template_path, "w");
    SHC_TEST_ASSERT(tmp_file != NULL, "temp file created");
    fclose(tmp_file);

    SHC_TEST_ASSERT(shc_store_save(template_path, &devices), "state save");

    SHCArray devices_copy = shc_config_load_devices("tests/fixtures/devices.conf");
    SHC_TEST_ASSERT(shc_store_load(template_path, &devices_copy), "state load");

    SHCDevice *device = shc_controller_find(&devices_copy, "test-light-1");
    SHC_TEST_ASSERT(device != NULL, "device found after load");

    shc_controller_destroy_devices(&devices);
    shc_controller_destroy_devices(&devices_copy);
    unlink(template_path);
    return true;
}

int main(void) {
    struct {
        const char *name;
        bool (*fn)(void);
    } tests[] = {
        {"string utilities", test_string_utilities},
        {"string builder", test_string_builder},
        {"config load", test_config_load},
        {"scene load", test_scene_load},
        {"controller actions", test_controller_actions},
        {"scene apply", test_scene_apply},
        {"store roundtrip", test_store_roundtrip},
    };

    size_t failures = 0;
    for (size_t i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
        bool ok = tests[i].fn();
        printf("[TEST] %s: %s\n", tests[i].name, ok ? "ok" : "failed");
        if (!ok) {
            failures++;
        }
    }

    if (failures > 0) {
        fprintf(stderr, "[TEST] %zu test(s) failed\n", failures);
        return 1;
    }

    printf("[TEST] All tests passed\n");
    return 0;
}
