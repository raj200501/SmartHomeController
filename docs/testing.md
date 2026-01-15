# Testing Guide

This guide explains how to run tests and verification checks for the Smart Home Controller CLI.

## Test Layers

The repository contains multiple layers of validation:

1. **Unit Tests** — run by `scripts/test.sh`
2. **Smoke/Integration Tests** — run by `scripts/verify.sh`
3. **CI Workflow** — runs `scripts/verify.sh` on every push/pull request

## Unit Tests

The test suite lives in `tests/test_main.m`. It exercises the following components:

- String utilities and string builder
- Device config parsing
- Scene config parsing
- Controller actions
- Scene application
- State store persistence

Run the tests locally:

```bash
./scripts/test.sh
```

The script compiles all Objective-C source files (excluding `main.m`) and produces a single test binary.

## Smoke/Integration Tests

The smoke tests validate end-to-end behavior with the default configuration files.

Run the verification script:

```bash
./scripts/verify.sh
```

### What the Smoke Tests Validate

- **Status JSON** contains a `devices` array.
- **Light control** returns the expected success message.
- **Thermostat control** returns the expected success message.
- **Scene execution** applies multiple actions and prints per-device output.
- **Dashboard output** contains the expected header.

## CI Expectations

CI runs on GitHub Actions and performs the following:

1. Check out the repository.
2. Execute `./scripts/verify.sh`.

Any failure in unit tests or smoke tests will fail the workflow.

## Adding New Tests

When introducing a new module or device type, add tests in `tests/test_main.m` following the existing pattern:

1. Create a helper function that returns `bool`.
2. Add the function to the `tests` array in `main`.
3. Use `SHC_TEST_ASSERT` for deterministic checks.

## Test Data

Test fixtures live in `tests/fixtures/` and are safe to modify:

- `devices.conf`
- `scenes.conf`

Fixtures are kept small to ensure fast test execution.

## Troubleshooting Tests

- **Compilation errors:** Confirm `clang` and `make` are installed.
- **Missing fixture files:** Ensure test fixture paths are correct.
- **Unexpected failures:** Run `./scripts/test.sh` directly to isolate unit test issues.

