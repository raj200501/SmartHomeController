#ifndef SHC_STORE_H
#define SHC_STORE_H

#include "SHCArray.h"

bool shc_store_load(const char *path, SHCArray *devices);
bool shc_store_save(const char *path, const SHCArray *devices);

#endif
