# Smart Home Controller

Smart Home Controller is a **deterministic Objective-C command-line simulator** for a smart home hub. It models lights, thermostats, and security cameras, exposes a CLI for controlling them, persists state to disk, and includes a scene system for automating multi-device changes.

This repository also includes the original iOS storyboard assets, but the runnable artifact in this environment is the CLI simulator built from Objective-C source. The README documents exactly how to build, run, and verify that simulator.

## Features

- **Control Smart Lights:** Turn lights on/off, change brightness.
- **Adjust Thermostat Settings:** Set temperature targets with unit-aware clamping.
- **View Security Cameras:** Toggle streaming and take snapshots.
- **Central Dashboard:** Aggregated status summary.
- **Scenes:** Apply multi-device presets (e.g., “evening” or “away”).
- **Deterministic State:** State file persists between runs.

## Requirements

- `clang` with C99 support (available on macOS and most Linux environments)
- `make`

## Repository Layout

- `Sources/` — Objective-C (C99) implementation for the CLI.
- `config/` — Default device and scene configuration.
- `data/` — Runtime state storage.
- `scripts/` — Run/test/verify entrypoints.
- `tests/` — Unit tests and fixtures.
- `docs/` — Architecture and usage references.

## Configuration

### Devices (`config/devices.conf`)

Each line defines a device:

```
<type>,<id>,<name>,<location>,<key=value,...>
```

Examples:

```
light,light-living,Living Room Lamp,Living Room,brightness=75
thermostat,thermo-main,Main Thermostat,Hallway,current=21.0,target=22.0,units=C
camera,cam-front,Front Door Camera,Front Door,streaming=on
```

### Scenes (`config/scenes.conf`)

Scenes are defined in blocks:

```
scene,<name>,<summary>
<device_type>,<device_id>,<attributes>
end
```

Example:

```
scene,evening,Relaxing evening setup
light,light-living,power=on,brightness=40
thermostat,thermo-main,target=21.5
camera,cam-front,streaming=on
end
```

### Environment Variables

- `SHC_CONFIG` — overrides the device config path (default `config/devices.conf`).
- `SHC_SCENES` — overrides the scene config path (default `config/scenes.conf`).
- `SHC_STATE` — overrides the state file path (default `data/state.db`).
- `SHC_LOG_LEVEL` — `debug`, `info`, `warn`, or `error`.

A sample `.env.example` is provided.

## Commands

All commands are run via the `smart_home_controller` binary (built automatically by the scripts):

```
./bin/smart_home_controller status [--config path] [--state path] [--json]
./bin/smart_home_controller dashboard [--config path] [--state path]
./bin/smart_home_controller scene list [--scenes path]
./bin/smart_home_controller scene show <name> [--scenes path]
./bin/smart_home_controller scene run <name> [--scenes path] [--state path]
./bin/smart_home_controller light on <id> [--config path] [--state path]
./bin/smart_home_controller light off <id> [--config path] [--state path]
./bin/smart_home_controller light brightness <id> <0-100> [--config path] [--state path]
./bin/smart_home_controller thermostat set <id> <temp> [--config path] [--state path]
./bin/smart_home_controller camera stream <id> <on|off> [--config path] [--state path]
./bin/smart_home_controller camera snapshot <id> [--config path] [--state path]
```

## Verified Quickstart

These commands were executed successfully in the workspace:

```bash
./scripts/run.sh status
./scripts/run.sh dashboard
./scripts/run.sh light on light-living
./scripts/run.sh thermostat set thermo-main 23.0
./scripts/run.sh scene run evening
```

## Verified Verification

This command runs unit tests and smoke/integration checks:

```bash
./scripts/verify.sh
```

## Troubleshooting

- **Missing config files:** Ensure `config/devices.conf` and `config/scenes.conf` exist or set `SHC_CONFIG`/`SHC_SCENES`.
- **State not persisting:** Check permissions for `data/state.db` or set `SHC_STATE`.
- **Build errors:** Confirm `clang` and `make` are installed and that you can compile C99 code.

## Additional Documentation

- [Architecture Overview](docs/architecture.md)
- [CLI Reference](docs/cli-reference.md)
- [Configuration Reference](docs/config-reference.md)
- [Testing Guide](docs/testing.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
