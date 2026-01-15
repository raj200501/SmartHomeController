#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

mkdir -p data

make

if [[ $# -eq 0 ]]; then
  exec ./bin/smart_home_controller dashboard
else
  exec ./bin/smart_home_controller "$@"
fi
