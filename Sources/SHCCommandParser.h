#ifndef SHC_COMMAND_PARSER_H
#define SHC_COMMAND_PARSER_H

#include "SHCCommand.h"

SHCCommand *shc_parse_command(int argc, char **argv);
void shc_print_help(const char *program);

#endif
