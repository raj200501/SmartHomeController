# Troubleshooting Guide

This guide documents common issues and how to resolve them when running Smart Home Controller.

## Build Issues

### `clang: command not found`

Install a C compiler:

- macOS: `xcode-select --install`
- Ubuntu: `sudo apt-get install clang`

### Warnings Treated as Errors

The build uses `-Werror`. If you modify the code, ensure new warnings are resolved rather than suppressed.

## Runtime Issues

### `Failed to open config file`

Ensure the config files exist:

```
config/devices.conf
config/scenes.conf
```

Or override the path with environment variables:

```
SHC_CONFIG=/path/to/devices.conf
SHC_SCENES=/path/to/scenes.conf
```

### `Light not found` / `Thermostat not found`

Verify the device ID exists in `config/devices.conf` and that the command uses the same ID.

### State Not Persisting

The CLI saves state to `data/state.db` by default. If the state file is missing or unwritable:

1. Ensure the `data/` directory exists.
2. Check permissions for `data/state.db`.
3. Use `SHC_STATE=/tmp/state.db` as a temporary override.

### Scene Not Found

Check `config/scenes.conf` for the scene name. Scene names are case-sensitive.

## Verification Failures

### Unit Tests Failing

Run the unit tests directly and inspect the failing test name:

```
./scripts/test.sh
```

### Smoke Tests Failing

Run the verification script to see which check fails:

```
./scripts/verify.sh
```

Inspect the files under `build/` for intermediate output:

- `build/verify_status.json`
- `build/verify_light.txt`
- `build/verify_thermo.txt`
- `build/verify_scene.txt`
- `build/verify_dashboard.txt`

## Logging

Enable verbose logging to troubleshoot parsing and configuration issues:

```
SHC_LOG_LEVEL=debug ./bin/smart_home_controller status
```

Or use the CLI flag:

```
./bin/smart_home_controller status --verbose
```

## Known Limitations

- This repository does not include a runnable iOS UI build for Linux environments.
- The CLI simulator is intended to validate the device control logic and automation behavior.

