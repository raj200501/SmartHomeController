#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

mkdir -p build/tests

if command -v rg >/dev/null 2>&1; then
  SOURCES=$(rg --files -g 'Sources/*.m' | rg -v 'Sources/main.m')
else
  SOURCES=$(find Sources -name '*.m' | grep -v 'Sources/main.m')
fi

clang -std=c99 -Wall -Wextra -Werror -I Sources \
  $SOURCES tests/test_main.m \
  -o build/tests/shc_tests

./build/tests/shc_tests
