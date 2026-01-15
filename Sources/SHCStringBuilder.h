#ifndef SHC_STRING_BUILDER_H
#define SHC_STRING_BUILDER_H

#include "SHCTypes.h"

typedef struct {
    char *buffer;
    size_t length;
    size_t capacity;
} SHCStringBuilder;

void shc_sb_init(SHCStringBuilder *builder);
void shc_sb_append(SHCStringBuilder *builder, const char *text);
void shc_sb_append_char(SHCStringBuilder *builder, char value);
void shc_sb_appendf(SHCStringBuilder *builder, const char *format, ...);
char *shc_sb_build(SHCStringBuilder *builder);
void shc_sb_reset(SHCStringBuilder *builder);
void shc_sb_destroy(SHCStringBuilder *builder);

#endif
