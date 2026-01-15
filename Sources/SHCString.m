#include "SHCString.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *shc_strdup(const char *value) {
    if (!value) {
        return NULL;
    }

    size_t len = strlen(value) + 1;
    char *copy = malloc(len);
    if (!copy) {
        fprintf(stderr, "[shc] Failed to allocate memory for string copy.\n");
        exit(1);
    }
    memcpy(copy, value, len);
    return copy;
}

char *shc_strtolower(const char *value) {
    if (!value) {
        return NULL;
    }

    size_t len = strlen(value);
    char *lower = malloc(len + 1);
    if (!lower) {
        fprintf(stderr, "[shc] Failed to allocate lowercase buffer.\n");
        exit(1);
    }

    for (size_t i = 0; i < len; i++) {
        lower[i] = (char)tolower((unsigned char)value[i]);
    }
    lower[len] = '\0';
    return lower;
}

char *shc_strtrim(const char *value) {
    if (!value) {
        return NULL;
    }

    const char *start = value;
    while (*start && isspace((unsigned char)*start)) {
        start++;
    }

    const char *end = value + strlen(value);
    while (end > start && isspace((unsigned char)*(end - 1))) {
        end--;
    }

    size_t len = (size_t)(end - start);
    char *result = malloc(len + 1);
    if (!result) {
        fprintf(stderr, "[shc] Failed to allocate trimmed string.\n");
        exit(1);
    }

    memcpy(result, start, len);
    result[len] = '\0';
    return result;
}

bool shc_starts_with(const char *value, const char *prefix) {
    if (!value || !prefix) {
        return false;
    }

    size_t prefix_len = strlen(prefix);
    return strncmp(value, prefix, prefix_len) == 0;
}

bool shc_ends_with(const char *value, const char *suffix) {
    if (!value || !suffix) {
        return false;
    }

    size_t value_len = strlen(value);
    size_t suffix_len = strlen(suffix);
    if (suffix_len > value_len) {
        return false;
    }

    return strcmp(value + value_len - suffix_len, suffix) == 0;
}

char *shc_strreplace(const char *value, const char *target, const char *replacement) {
    if (!value || !target || !replacement) {
        return NULL;
    }

    size_t value_len = strlen(value);
    size_t target_len = strlen(target);
    size_t replacement_len = strlen(replacement);

    if (target_len == 0) {
        return shc_strdup(value);
    }

    size_t count = 0;
    const char *cursor = value;
    while ((cursor = strstr(cursor, target)) != NULL) {
        count++;
        cursor += target_len;
    }

    if (count == 0) {
        return shc_strdup(value);
    }

    size_t result_len = value_len + (replacement_len - target_len) * count;
    char *result = malloc(result_len + 1);
    if (!result) {
        fprintf(stderr, "[shc] Failed to allocate replace buffer.\n");
        exit(1);
    }

    const char *input_cursor = value;
    char *output_cursor = result;
    while ((cursor = strstr(input_cursor, target)) != NULL) {
        size_t segment_len = (size_t)(cursor - input_cursor);
        memcpy(output_cursor, input_cursor, segment_len);
        output_cursor += segment_len;
        memcpy(output_cursor, replacement, replacement_len);
        output_cursor += replacement_len;
        input_cursor = cursor + target_len;
    }

    size_t remaining_len = strlen(input_cursor);
    memcpy(output_cursor, input_cursor, remaining_len);
    output_cursor += remaining_len;
    output_cursor[0] = '\0';

    return result;
}

char **shc_split(const char *value, char delimiter, size_t *count) {
    if (!value) {
        if (count) {
            *count = 0;
        }
        return NULL;
    }

    size_t capacity = 4;
    size_t items = 0;
    char **parts = calloc(capacity, sizeof(char *));
    if (!parts) {
        fprintf(stderr, "[shc] Failed to allocate split array.\n");
        exit(1);
    }

    const char *start = value;
    const char *cursor = value;
    while (*cursor) {
        if (*cursor == delimiter) {
            size_t len = (size_t)(cursor - start);
            char *segment = malloc(len + 1);
            if (!segment) {
                fprintf(stderr, "[shc] Failed to allocate split segment.\n");
                exit(1);
            }
            memcpy(segment, start, len);
            segment[len] = '\0';

            if (items >= capacity) {
                capacity *= 2;
                char **resized = realloc(parts, capacity * sizeof(char *));
                if (!resized) {
                    fprintf(stderr, "[shc] Failed to grow split array.\n");
                    exit(1);
                }
                parts = resized;
            }

            parts[items++] = segment;
            start = cursor + 1;
        }
        cursor++;
    }

    size_t len = (size_t)(cursor - start);
    char *segment = malloc(len + 1);
    if (!segment) {
        fprintf(stderr, "[shc] Failed to allocate split tail segment.\n");
        exit(1);
    }
    memcpy(segment, start, len);
    segment[len] = '\0';

    if (items >= capacity) {
        capacity += 1;
        char **resized = realloc(parts, capacity * sizeof(char *));
        if (!resized) {
            fprintf(stderr, "[shc] Failed to grow split array (tail).\n");
            exit(1);
        }
        parts = resized;
    }
    parts[items++] = segment;

    if (count) {
        *count = items;
    }

    return parts;
}

void shc_split_free(char **parts, size_t count) {
    if (!parts) {
        return;
    }

    for (size_t i = 0; i < count; i++) {
        free(parts[i]);
    }
    free(parts);
}
