#ifndef SHC_SCENE_RUNNER_H
#define SHC_SCENE_RUNNER_H

#include "SHCArray.h"
#include "SHCScene.h"
#include "SHCStringBuilder.h"

bool shc_scene_apply(const SHCScene *scene, SHCArray *devices, SHCStringBuilder *builder);

#endif
