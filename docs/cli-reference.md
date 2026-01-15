# CLI Reference

This reference provides detailed usage for the Smart Home Controller CLI. It mirrors the commands defined by the parser and documents expected output patterns.

## Global Flags

| Flag | Description |
| --- | --- |
| `--config <path>` | Override the device config file. |
| `--scenes <path>` | Override the scene config file. |
| `--state <path>` | Override the state file. |
| `--json` | Output device status in JSON. |
| `--verbose` | Enable debug logging. |

## Commands

### `status`

Print the current state of all devices.

```
./bin/smart_home_controller status
```

Expected output (human-readable):

```
Living Room Lamp (light-living) in Living Room [online=yes] | power=on brightness=75%
Kitchen Lights (light-kitchen) in Kitchen [online=yes] | power=on brightness=100%
Main Thermostat (thermo-main) in Hallway [online=yes] | current=21.0C target=22.0C range=16.0-29.5C
Front Door Camera (cam-front) in Front Door [online=yes] | streaming=on last_snapshot=0
```

JSON output:

```
./bin/smart_home_controller status --json
```

Expected output:

```
{"devices":[{"id":"light-living",...}]}
```

### `dashboard`

Show an aggregated dashboard summary of the smart home state.

```
./bin/smart_home_controller dashboard
```

Example output:

```
Smart Home Dashboard
====================
Lights: 2/2 on
Cameras: 1/2 streaming
Thermostats: 1 average 21.0C
```

### `scene list`

List all scenes configured in `config/scenes.conf`.

```
./bin/smart_home_controller scene list
```

Example output:

```
evening - Relaxing evening setup
away - Secure the home
```

### `scene show <name>`

Show the full detail of a scene.

```
./bin/smart_home_controller scene show evening
```

Example output:

```
Scene: evening
Summary: Relaxing evening setup
Actions:
  - light power on light-living => on
  - light power off light-kitchen => off
  - thermostat target on thermo-main => 21.5
  - camera stream on cam-front => on
```

### `scene run <name>`

Apply a scene to the current device set.

```
./bin/smart_home_controller scene run evening
```

Example output:

```
light-living: light power on => ok
light-kitchen: light power off => ok
thermo-main: thermostat target => ok
cam-front: camera stream on => ok
```

### `light on <id>` / `light off <id>`

Toggle light power state.

```
./bin/smart_home_controller light on light-living
```

Example output:

```
Light light-living turned on.
```

### `light brightness <id> <0-100>`

Set a light’s brightness level. Brightness is clamped to 0-100.

```
./bin/smart_home_controller light brightness light-living 40
```

Example output:

```
Light light-living brightness set to 40%.
```

### `thermostat set <id> <temp>`

Set a thermostat’s target temperature. The value is clamped based on units.

```
./bin/smart_home_controller thermostat set thermo-main 23.0
```

Example output:

```
Thermostat thermo-main target set to 23.0.
```

### `camera stream <id> <on|off>`

Toggle camera streaming.

```
./bin/smart_home_controller camera stream cam-front on
```

Example output:

```
Camera cam-front streaming on.
```

### `camera snapshot <id>`

Capture a snapshot. The snapshot counter increments each time.

```
./bin/smart_home_controller camera snapshot cam-front
```

Example output:

```
Camera cam-front snapshot captured: 1
```

## Exit Codes

| Exit Code | Meaning |
| --- | --- |
| `0` | Command succeeded. |
| `1` | Command failed (missing device, invalid config, etc.). |

## Examples with Overrides

Use alternate config files:

```
./bin/smart_home_controller status --config tests/fixtures/devices.conf
```

Change the state file location:

```
./bin/smart_home_controller dashboard --state /tmp/custom-state.db
```

Use a custom scene file:

```
./bin/smart_home_controller scene list --scenes tests/fixtures/scenes.conf
```

## Notes

- The CLI requires device definitions to exist in the device config file. If a device ID is not present, commands for that device will fail.
- Scene commands require a scene config file. If the file is missing or invalid, the command exits with an error.
- State persistence is optional but recommended for realistic workflows.

