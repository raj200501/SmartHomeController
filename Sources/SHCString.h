#ifndef SHC_STRING_H
#define SHC_STRING_H

#include "SHCTypes.h"

char *shc_strdup(const char *value);
char *shc_strtolower(const char *value);
char *shc_strtrim(const char *value);
bool shc_starts_with(const char *value, const char *prefix);
bool shc_ends_with(const char *value, const char *suffix);
char *shc_strreplace(const char *value, const char *target, const char *replacement);

char **shc_split(const char *value, char delimiter, size_t *count);
void shc_split_free(char **parts, size_t count);

#endif
