#include "SHCArray.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void shc_array_grow(SHCArray *array, size_t needed) {
    if (array->capacity >= needed) {
        return;
    }

    size_t new_capacity = array->capacity == 0 ? 8 : array->capacity;
    while (new_capacity < needed) {
        new_capacity *= 2;
    }

    void **resized = realloc(array->items, new_capacity * sizeof(void *));
    if (!resized) {
        fprintf(stderr, "[shc] Failed to grow array to %zu items.\n", new_capacity);
        exit(1);
    }

    array->items = resized;
    array->capacity = new_capacity;
}

void shc_array_init(SHCArray *array) {
    array->items = NULL;
    array->count = 0;
    array->capacity = 0;
}

void shc_array_append(SHCArray *array, void *item) {
    shc_array_grow(array, array->count + 1);
    array->items[array->count++] = item;
}

void *shc_array_get(const SHCArray *array, size_t index) {
    if (!array || index >= array->count) {
        return NULL;
    }
    return array->items[index];
}

void shc_array_remove_at(SHCArray *array, size_t index) {
    if (!array || index >= array->count) {
        return;
    }

    if (index + 1 < array->count) {
        memmove(&array->items[index], &array->items[index + 1],
                (array->count - index - 1) * sizeof(void *));
    }

    array->count--;
}

void shc_array_clear(SHCArray *array, void (*free_fn)(void *)) {
    if (!array) {
        return;
    }

    if (free_fn) {
        for (size_t i = 0; i < array->count; i++) {
            free_fn(array->items[i]);
        }
    }

    array->count = 0;
}

void shc_array_destroy(SHCArray *array, void (*free_fn)(void *)) {
    if (!array) {
        return;
    }

    shc_array_clear(array, free_fn);
    free(array->items);
    array->items = NULL;
    array->capacity = 0;
}
