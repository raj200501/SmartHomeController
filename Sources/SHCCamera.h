#ifndef SHC_CAMERA_H
#define SHC_CAMERA_H

#include "SHCDevice.h"

typedef struct {
    SHCDevice base;
    bool isStreaming;
    int lastSnapshotId;
} SHCCamera;

SHCCamera *shc_camera_create(const char *identifier,
                             const char *name,
                             const char *location,
                             bool streaming);
void shc_camera_destroy(SHCCamera *camera);
void shc_camera_set_streaming(SHCCamera *camera, bool streaming);
int shc_camera_snapshot(SHCCamera *camera);
void shc_camera_describe(const SHCCamera *camera, SHCStringBuilder *builder);

#endif
