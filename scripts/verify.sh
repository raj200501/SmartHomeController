#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

./scripts/test.sh

./scripts/run.sh status --json > build/verify_status.json
if command -v rg >/dev/null 2>&1; then
  if ! rg -q '"devices"' build/verify_status.json; then
    echo "status output missing devices list" >&2
    exit 1
  fi
else
  if ! grep -q '"devices"' build/verify_status.json; then
    echo "status output missing devices list" >&2
    exit 1
  fi
fi

./scripts/run.sh light on light-living > build/verify_light.txt
if command -v rg >/dev/null 2>&1; then
  rg -q "Light light-living turned on" build/verify_light.txt
else
  grep -q "Light light-living turned on" build/verify_light.txt
fi

./scripts/run.sh thermostat set thermo-main 23.0 > build/verify_thermo.txt
if command -v rg >/dev/null 2>&1; then
  rg -q "Thermostat thermo-main target set" build/verify_thermo.txt
else
  grep -q "Thermostat thermo-main target set" build/verify_thermo.txt
fi

./scripts/run.sh scene run evening > build/verify_scene.txt
if command -v rg >/dev/null 2>&1; then
  rg -q "light-living" build/verify_scene.txt
  rg -q "thermo-main" build/verify_scene.txt
else
  grep -q "light-living" build/verify_scene.txt
  grep -q "thermo-main" build/verify_scene.txt
fi

./scripts/run.sh dashboard > build/verify_dashboard.txt
if command -v rg >/dev/null 2>&1; then
  rg -q "Smart Home Dashboard" build/verify_dashboard.txt
else
  grep -q "Smart Home Dashboard" build/verify_dashboard.txt
fi
