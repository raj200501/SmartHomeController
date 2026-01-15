#include "SHCAttributes.h"

#include "SHCString.h"

#include <stdlib.h>
#include <string.h>

char *shc_attributes_value(const char *attributes, const char *key) {
    if (!attributes || !key) {
        return NULL;
    }

    size_t attr_count = 0;
    char **pairs = shc_split(attributes, ',', &attr_count);
    char *result = NULL;

    for (size_t i = 0; i < attr_count; i++) {
        size_t pair_count = 0;
        char **pair = shc_split(pairs[i], '=', &pair_count);
        if (pair_count == 2) {
            char *trim_key = shc_strtrim(pair[0]);
            if (strcmp(trim_key, key) == 0) {
                result = shc_strtrim(pair[1]);
                free(trim_key);
                shc_split_free(pair, pair_count);
                break;
            }
            free(trim_key);
        }
        shc_split_free(pair, pair_count);
    }

    shc_split_free(pairs, attr_count);
    return result;
}
