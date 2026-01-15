#ifndef SHC_SCENE_CONFIG_H
#define SHC_SCENE_CONFIG_H

#include "SHCArray.h"
#include "SHCScene.h"

SHCArray shc_scene_config_load(const char *path);
SHCScene *shc_scene_config_find(SHCArray *scenes, const char *name);

#endif
