# nixos/AGENTS.md

## Overview

This directory contains the **NixOS system configuration** for personal machines. It uses **Nix Flakes** for system management and **Home Manager** for user environments. 

### Key Technologies
- **System**: NixOS (Unstable channel by default, with a 24.11 stable overlay for pinned packages).
- **Configuration Manager**: Flakes (`flake.nix`).
- **User Environment**: Home Manager (integrated into the NixOS config).
- **Secret Management**: `sops-nix` (for secrets) + `git-crypt` (for personal configuration). See "Managing Secrets".

## Directory Structure

- **`flake.nix`**: Entry point defining `nixosConfigurations` for all hosts.
- **`flake.lock`**: Pinned input versions. Do not hand-edit.
- **`hosts/`**: Host-specific configurations (one subdir per host).
  - `workstation/`: Main work desktop.
  - `home-wsl/`: Windows Subsystem for Linux setup (uses `nixos-wsl` module).
  - `dedi-sm/`: Dedicated server.
- **`modules/`**: Reusable modules.
  - `nixos/`: System-level modules (services, hardware, networking). Follow the **Wrapper Pattern**.
  - `home-manager/`: User-level modules (applications, dotfiles, shell). Organized by category (`shells/`, `display/`, `dev/`, `devops/`, `terminals/`, and flat app modules). Follow the **Wrapper Pattern**.
  - `shells/`: Nix devShells (rust, go, nodejs, python, plakar) — consumed via `pkgs.callPackage`, not NixOS modules.
- **`lib/`**: Custom library (`myLib`) aggregating helpers (`landrun.nix`, `bwrap.nix`, `folder.nix`). Imported as `myLib` via `specialArgs`.
- **`overlays.nix`**: Package overlays (e.g., pinning `nixpkgs-stable` and `nixpkgs-anytype`).

## Architecture & Patterns

### 1. The Wrapper Pattern (NixOS)

The configuration uses a custom module system wrapper. Instead of directly enabling services in `configuration.nix`, we define custom options (usually `modules.<service>.enable`) in `modules/nixos/<service>.nix`.
- **Example**: To enable SSH, set `modules.ssh.enable = true;` in a host configuration, which internally configures `services.openssh`.
- The full set of available system modules is aggregated in `modules/nixos/default.nix`.

### 2. The `mkHost` Helper

`flake.nix` defines a `mkHost` helper that standardizes host construction. Each host is built with:
- `specialArgs = { inherit inputs system myLib; }` — so hosts and home-manager can access flake inputs and `myLib`.
- A shared module set applied to every host:
  - `./hosts/${host}` (host entrypoint)
  - `./overlays.nix`
  - `home-manager.nixosModules.home-manager` (with `useGlobalPkgs`, `useUserPackages`, `backupFileExtension = "backup"`)
  - `sops-nix.nixosModules.sops` (system-level secrets)
  - **Shared home-manager modules**: `sops-nix.homeManagerModules.sops`, `agent-skills.homeManagerModules.default`, `neru.homeManagerModules.default`, `ponos.homeManagerModules.default`.
- Host-specific extra modules are passed as the third argument (e.g., `nixos-wsl.nixosModules.default` for `home-wsl`).

### 3. Host Definitions

Hosts are defined in `hosts/<hostname>/default.nix`. They import:
- Relevant system modules from `modules/nixos/` (via `../../modules/nixos`).
- Hardware configuration (`hardware-configuration.nix`).
- Host config (`config.nix`) and secrets (`sops.nix`).
- User configurations (`users/<user>.nix`), which home-manager mounts via `mkHost`.

Current hosts: `workstation`, `home-wsl`, `dedi-sm`.

### 4. Home Manager Integration

User configurations are managed via Home Manager, imported directly into the NixOS system configuration by `mkHost`.
- **Modules**: Located in `modules/home-manager/`.
- **Categories**: `shells/` (bash, nushell), `terminals/` (ghostty, wezterm, zellij), `display/` (waybar, dunst, hypridle), `dev/` (postman), `devops/` (kubectl, k9s), plus many flat application modules (e.g., `git-crypt.nix`, `direnv.nix`, `starship.nix`).
- The full set of home-manager modules is aggregated in `modules/home-manager/default.nix`.
- Per-host user overrides live in `hosts/<host>/users/ftouya.config-*.nix` (e.g., `ftouya.config-shell.nix`, `ftouya.config-dev.nix`).

## Do's and Don'ts

- **DO** use the `modules.<name>.enable` pattern for new services.
- **DON'T** manually edit `flake.lock` unless specifically updating dependencies (`nix flake update`).
- **DON'T** hardcode absolute paths; use Nix paths (e.g., `./.`).
