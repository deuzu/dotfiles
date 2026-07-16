# keyboards/AGENTS.md

## Overview

This directory contains **QMK firmware source code** for custom split keyboards.

- **Firmware Framework**: QMK.
- **Hardware**: Split keyboards (Cantor, Piantor).
- **Build**: Handled by GitHub Actions CI/CD.

## Directory Structure

Each keyboard has its own subdirectory. The layout follows the standard QMK user keymap convention.

- **`cantor/`**: Configuration for the Cantor keyboard.
- **`piantor/`**: Configuration for the Piantor keyboard.

Each keyboard directory contains:
- `config.h`, `keyboard.json` (where applicable): Keyboard-level configuration.
- `keymaps/deuzu/`: The personal keymap (`deuzu`).
  - `keymap.c`: The main keymap definition (C source).
  - `keymap.json`: JSON representation of the keymap (where present).
  - `config.h`: Keymap-level configuration (e.g., combos, tapping terms).
  - `rules.mk`: Build feature flags for the keymap.

## Workflows for Agents

### Editing a Keymap

1.  **Locate**: `keyboards/<keyboard>/keymaps/deuzu/keymap.c` for the layer/key definitions; `config.h` for behavior tweaks; `rules.mk` for feature flags.
2.  **Edit**: Modify the C/JSON source.
3.  **Validate**: Rely on GitHub Actions (`.github/workflows/keyboards.yaml`) to build the `.uf2` / `.hex` artifacts on push.

### Building Firmware

- Firmware is built automatically by CI/CD when changes are pushed to `keyboards/`.
- The workflow produces `.uf2` (RP2040-based, e.g. Piantor) or `.hex` (AVR-based, e.g. Cantor) files.

## Do's and Don'ts

- **DO** keep QMK changes scoped to this directory.
- **DON'T** attempt to build firmware locally; let CI/CD handle it.
