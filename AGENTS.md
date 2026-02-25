# AGENTS.md

## Repository Overview

This repository manages the NixOS configuration for my personal machines and custom keyboard firmware. It uses **Nix Flakes** for system management and **Home Manager** for user environments.

### Key Technologies
- **System**: NixOS (Unstable channel by default, with Stable overlays).
- **Configuration Manager**: Flakes.
- **User Environment**: Home Manager.
- **Secret Management**: `git-crypt` (Active), migrating to `sops-nix`.
- **Firmware**: QMK (for split keyboards).
- **Key Tool Flakes**: `stylix`, `niri`, `zen-browser`, `helix`.
- **Formatting**: `nixpkgs-fmt` or `alejandra` (check `flake.nix` devShell).

## Directory Structure

The repository is divided into two main sections: system configuration (`nixos/`) and keyboard firmware (`keyboards/`).

- **`keyboards/`**: QMK source code for custom split keyboards. **Independent of NixOS build.**
  - `cantor/`: Configuration for Cantor keyboard.
  - `piantor/`: Configuration for Piantor keyboard.
- **`nixos/`**: Main system configuration.
  - **`flake.nix`**: The entry point defining `nixosConfigurations`.
  - **`hosts/`**: Host-specific configurations.
    - `workstation/`: Main desktop.
    - `home-wsl/`: Windows Subsystem for Linux setup.
  - **`modules/`**: Reusable modules.
    - `nixos/`: System-level modules (services, hardware, networking).
    - `home-manager/`: User-level modules (applications, dotfiles, shell).
  - **`overlays.nix`**: Package overlays (e.g., pinning stable packages).

## Architecture & Patterns

### 1. The Wrapper Pattern (NixOS)
The configuration uses a custom module system wrapper. Instead of directly enabling services in `configuration.nix`, we define custom options (usually `modules.<service>.enable`) in `nixos/modules/nixos/<service>.nix`.
- **Example**: To enable SSH, set `modules.ssh.enable = true;` in a host configuration, which internally configures `services.openssh`.

### 2. Host Definitions
Hosts are defined in `nixos/hosts/<hostname>/default.nix`. They import:
- Relevant system modules from `nixos/modules/nixos/`.
- Hardware configuration (`hardware-configuration.nix`).
- User configurations (`users/<user>.nix`).

### 3. Home Manager Integration
User configurations are managed via Home Manager, often imported directly into the NixOS system configuration.
- **Modules**: Located in `nixos/modules/home-manager/`.
- **Categories**: `shells`, `text-editors`, `display`, `dev`, etc.

### 4. Keyboard Firmware (QMK)
The `keyboards/` directory contains QMK configurations for the Cantor and Piantor keyboards.
- **Independence**: These files are **NOT** imported by `flake.nix` or any NixOS module.
- **Build Process**: Managed via GitHub Actions (`.github/workflows/keyboards.yaml`) which builds the `.uf2` or `.hex` firmware files.

## Workflows for Agents

### Adding a Package
1.  **Identify Scope**:
    - **System-wide**: Use `environment.systemPackages` in a module under `nixos/modules/nixos/`.
    - **User-specific**: Use `home.packages` in a module under `nixos/modules/home-manager/`.
2.  **Locate Module**: Find the most relevant existing module (e.g., `text-editors/helix.nix` for Helix) or create a new one.
3.  **Enable**: Ensure the module is enabled in the host configuration (`nixos/hosts/<host>/default.nix` or `users/<user>.nix`).

### Modifying Configuration
1.  **Edit**: Modify the `.nix` files.
2.  **Format**: Apply standard formatting (`nix fmt`).
3.  **Validate**: Run `nixos-rebuild build --flake .#<host> --dry-run` to check for syntax errors.

### Managing Secrets
**CRITICAL**: This repository is currently in a hybrid state.
- **Status**: The repository is on the `sops` branch, but **`git-crypt` is still the active secret enforcement mechanism.**
- **Action**: **NEVER** commit secrets (API keys, passwords) in plain text.
- **Verification**: **ALWAYS** check `.gitattributes` to ensure secrets are encrypted before committing.

### Building Keyboards
- Do not attempt to build keyboards via Nix.
- These are built automatically by CI/CD when changes are pushed to `keyboards/`.

## Do's and Don'ts

- **DO** use the `modules.<name>.enable` pattern for new services.
- **DO** run `nix flake check` before committing complex changes.
- **DON'T** manually edit `flake.lock` unless specifically updating dependencies.
- **DON'T** hardcode absolute paths; use Nix paths (e.g., `./.`).
- **DON'T** mix QMK logic into NixOS modules; keep them separate.

## Useful Commands

- **Rebuild System**:
  ```bash
  nixos-rebuild switch --flake .#workstation
  ```
- **Update Flake Inputs**:
  ```bash
  nix flake update
  ```
- **Check Flake**:
  ```bash
  nix flake check
  ```
