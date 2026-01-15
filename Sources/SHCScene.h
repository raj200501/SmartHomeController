#ifndef SHC_SCENE_H
#define SHC_SCENE_H

#include "SHCArray.h"
#include "SHCSceneAction.h"
#include "SHCStringBuilder.h"

typedef struct {
    char *name;
    char *summary;
    SHCArray actions;
} SHCScene;

SHCScene *shc_scene_create(const char *name, const char *summary);
void shc_scene_destroy(SHCScene *scene);
void shc_scene_add_action(SHCScene *scene, SHCSceneAction *action);
void shc_scene_describe(const SHCScene *scene, SHCStringBuilder *builder);

#endif
