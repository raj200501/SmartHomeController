#ifndef SHC_LOGGER_H
#define SHC_LOGGER_H

#include "SHCTypes.h"

typedef enum {
    SHC_LOG_ERROR = 0,
    SHC_LOG_WARN = 1,
    SHC_LOG_INFO = 2,
    SHC_LOG_DEBUG = 3
} SHCLogLevel;

void shc_logger_set_level(SHCLogLevel level);
SHCLogLevel shc_logger_get_level(void);
void shc_log(SHCLogLevel level, const char *format, ...);

#endif
