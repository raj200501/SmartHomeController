#include "SHCLogger.h"

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

static SHCLogLevel current_level = SHC_LOG_INFO;

void shc_logger_set_level(SHCLogLevel level) {
    current_level = level;
}

SHCLogLevel shc_logger_get_level(void) {
    return current_level;
}

static const char *shc_level_label(SHCLogLevel level) {
    switch (level) {
        case SHC_LOG_ERROR:
            return "ERROR";
        case SHC_LOG_WARN:
            return "WARN";
        case SHC_LOG_INFO:
            return "INFO";
        case SHC_LOG_DEBUG:
            return "DEBUG";
        default:
            return "UNKNOWN";
    }
}

void shc_log(SHCLogLevel level, const char *format, ...) {
    if (level > current_level) {
        return;
    }

    time_t now = time(NULL);
    struct tm *utc = gmtime(&now);
    char timestamp[32] = {0};
    if (utc) {
        strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", utc);
    } else {
        strncpy(timestamp, "unknown-time", sizeof(timestamp) - 1);
    }

    fprintf(stderr, "[%s] %s: ", timestamp, shc_level_label(level));

    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);

    fprintf(stderr, "\n");
}
