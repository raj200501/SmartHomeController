#include "SHCCamera.h"

#include <stdio.h>
#include <stdlib.h>

SHCCamera *shc_camera_create(const char *identifier,
                             const char *name,
                             const char *location,
                             bool streaming) {
    SHCCamera *camera = calloc(1, sizeof(SHCCamera));
    if (!camera) {
        fprintf(stderr, "[shc] camera allocation failed.\n");
        exit(1);
    }

    SHCDevice *base = shc_device_create(identifier, name, location, SHC_DEVICE_CAMERA);
    if (!base) {
        free(camera);
        return NULL;
    }

    camera->base = *base;
    free(base);
    camera->isStreaming = streaming;
    camera->lastSnapshotId = 0;

    return camera;
}

void shc_camera_destroy(SHCCamera *camera) {
    if (!camera) {
        return;
    }

    shc_device_cleanup(&camera->base);
    free(camera);
}

void shc_camera_set_streaming(SHCCamera *camera, bool streaming) {
    if (!camera) {
        return;
    }

    camera->isStreaming = streaming;
}

int shc_camera_snapshot(SHCCamera *camera) {
    if (!camera) {
        return -1;
    }

    camera->lastSnapshotId += 1;
    return camera->lastSnapshotId;
}

void shc_camera_describe(const SHCCamera *camera, SHCStringBuilder *builder) {
    if (!camera || !builder) {
        return;
    }

    shc_device_describe(&camera->base, builder);
    shc_sb_appendf(builder,
                  " | streaming=%s last_snapshot=%d",
                  camera->isStreaming ? "on" : "off",
                  camera->lastSnapshotId);
}
