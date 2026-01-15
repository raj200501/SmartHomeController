# Configuration Reference

This document defines the configuration file formats for devices and scenes. The configuration files are designed to be human-readable, easy to diff, and deterministic to parse.

## Device Configuration (`config/devices.conf`)

### File Structure

- Each non-empty line defines a single device.
- Lines beginning with `#` are comments.
- Fields are comma-delimited.
- Attributes are additional key/value pairs appended to the line.

### Schema

```
<type>,<id>,<name>,<location>,<attributes>
```

| Field | Description | Required |
| --- | --- | --- |
| `type` | Device type (`light`, `thermostat`, `camera`) | ✅ |
| `id` | Unique device identifier | ✅ |
| `name` | Human-readable name | ✅ |
| `location` | Physical location (room) | ✅ |
| `attributes` | Comma-delimited key/value pairs | Optional |

### Light Attributes

| Key | Description | Example |
| --- | --- | --- |
| `brightness` | Initial brightness (0-100) | `brightness=75` |

Example:

```
light,light-living,Living Room Lamp,Living Room,brightness=75
```

### Thermostat Attributes

| Key | Description | Example |
| --- | --- | --- |
| `current` | Current temperature | `current=21.0` |
| `target` | Target temperature | `target=22.0` |
| `units` | Units (`C` or `F`) | `units=C` |

Example:

```
thermostat,thermo-main,Main Thermostat,Hallway,current=21.0,target=22.0,units=C
```

### Camera Attributes

| Key | Description | Example |
| --- | --- | --- |
| `streaming` | Initial stream state (`on`/`off`) | `streaming=on` |

Example:

```
camera,cam-front,Front Door Camera,Front Door,streaming=on
```

### Validation Rules

- Missing required fields cause a warning and the line is skipped.
- Unknown device types are logged as warnings.
- Brightness is clamped to the `0-100` range.
- Thermostat targets are clamped based on the unit system.

## Scene Configuration (`config/scenes.conf`)

### File Structure

Scene configuration is block-based:

```
scene,<name>,<summary>
<device_type>,<device_id>,<attributes>
end
```

- A `scene` header begins a scene block.
- Device action lines follow.
- `end` closes the block.

### Scene Header

| Field | Description | Required |
| --- | --- | --- |
| `name` | Scene identifier | ✅ |
| `summary` | Scene description | Optional |

Example:

```
scene,evening,Relaxing evening setup
```

### Scene Actions

Actions map to device types and attributes:

#### Light Actions

```
light,<device_id>,power=on
light,<device_id>,power=off
light,<device_id>,brightness=45
```

#### Thermostat Actions

```
thermostat,<device_id>,target=21.5
```

#### Camera Actions

```
camera,<device_id>,streaming=on
camera,<device_id>,streaming=off
```

### Validation Rules

- Actions outside a `scene` block are ignored with a warning.
- Unknown action types are logged and skipped.
- Missing required attributes (`target` for thermostats, `streaming` for cameras) cause a warning and the action is skipped.

## State File (`data/state.db`)

The state file captures the last-known runtime values. It is generated automatically, not typically edited by hand.

Example:

```
# Smart Home Controller state file
# Auto-generated, edit with caution

light-living power=on brightness=40
thermo-main current=21.0 target=22.5 units=C
cam-front streaming=on last_snapshot=3
```

### Notes

- The state file updates each time a command mutates device state.
- The file only applies to devices that exist in `devices.conf`.
- If the state file is missing, the application logs a warning and continues with defaults.

## Environment Overrides

You can override file locations with environment variables:

```
SHC_CONFIG=/path/to/devices.conf
SHC_SCENES=/path/to/scenes.conf
SHC_STATE=/path/to/state.db
```

These override the defaults used by `scripts/run.sh` and `scripts/verify.sh`.

