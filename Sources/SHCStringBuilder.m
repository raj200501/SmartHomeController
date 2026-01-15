#include "SHCStringBuilder.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void shc_sb_ensure_capacity(SHCStringBuilder *builder, size_t needed) {
    if (builder->capacity >= needed) {
        return;
    }

    size_t new_capacity = builder->capacity == 0 ? 128 : builder->capacity;
    while (new_capacity < needed) {
        new_capacity *= 2;
    }

    char *new_buffer = realloc(builder->buffer, new_capacity);
    if (!new_buffer) {
        fprintf(stderr, "[shc] Failed to allocate string builder buffer.\n");
        exit(1);
    }

    builder->buffer = new_buffer;
    builder->capacity = new_capacity;
}

void shc_sb_init(SHCStringBuilder *builder) {
    builder->buffer = NULL;
    builder->length = 0;
    builder->capacity = 0;
}

void shc_sb_append(SHCStringBuilder *builder, const char *text) {
    if (!text) {
        return;
    }

    size_t text_len = strlen(text);
    size_t needed = builder->length + text_len + 1;
    shc_sb_ensure_capacity(builder, needed);

    memcpy(builder->buffer + builder->length, text, text_len);
    builder->length += text_len;
    builder->buffer[builder->length] = '\0';
}

void shc_sb_append_char(SHCStringBuilder *builder, char value) {
    size_t needed = builder->length + 2;
    shc_sb_ensure_capacity(builder, needed);

    builder->buffer[builder->length] = value;
    builder->length += 1;
    builder->buffer[builder->length] = '\0';
}

void shc_sb_appendf(SHCStringBuilder *builder, const char *format, ...) {
    if (!format) {
        return;
    }

    va_list args;
    va_start(args, format);
    va_list args_copy;
    va_copy(args_copy, args);
    int needed_len = vsnprintf(NULL, 0, format, args_copy);
    va_end(args_copy);

    if (needed_len < 0) {
        va_end(args);
        return;
    }

    size_t needed = builder->length + (size_t)needed_len + 1;
    shc_sb_ensure_capacity(builder, needed);

    vsnprintf(builder->buffer + builder->length, (size_t)needed_len + 1, format, args);
    builder->length += (size_t)needed_len;
    va_end(args);
}

char *shc_sb_build(SHCStringBuilder *builder) {
    if (!builder->buffer) {
        char *empty = calloc(1, 1);
        return empty;
    }

    char *result = builder->buffer;
    builder->buffer = NULL;
    builder->length = 0;
    builder->capacity = 0;
    return result;
}

void shc_sb_reset(SHCStringBuilder *builder) {
    if (builder->buffer) {
        builder->buffer[0] = '\0';
    }
    builder->length = 0;
}

void shc_sb_destroy(SHCStringBuilder *builder) {
    free(builder->buffer);
    builder->buffer = NULL;
    builder->length = 0;
    builder->capacity = 0;
}
