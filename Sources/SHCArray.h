#ifndef SHC_ARRAY_H
#define SHC_ARRAY_H

#include "SHCTypes.h"

typedef struct {
    void **items;
    size_t count;
    size_t capacity;
} SHCArray;

void shc_array_init(SHCArray *array);
void shc_array_append(SHCArray *array, void *item);
void *shc_array_get(const SHCArray *array, size_t index);
void shc_array_remove_at(SHCArray *array, size_t index);
void shc_array_clear(SHCArray *array, void (*free_fn)(void *));
void shc_array_destroy(SHCArray *array, void (*free_fn)(void *));

#endif
