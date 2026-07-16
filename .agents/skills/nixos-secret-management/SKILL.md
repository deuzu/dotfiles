---
name: nixos-secret-management
description: Use when creating, modifying, removing or dealing with secrets.
---
# Managing Secrets

**CRITICAL**: Two secret mechanisms coexist. Choose the right one.

## sops-nix (for secrets)

- Wired **globally** into every host via `mkHost` (system + home-manager modules).
- Age keys configured in the repo-root `.sops.yaml` for `workstation` and `home-wsl` (not `dedi-sm`).
- Per-host SOPS files: `hosts/<host>/sops.nix` (module config) and secret YAMLs (`hosts/<host>/secrets.yaml`, `hosts/<host>/users/ftouya.secrets.yaml`).

## git-crypt (for personal configuration and sops secrets)

- Encrypts patterns per `.gitattributes`: `secrets.*`, `*.secrets.*`, `*.config*.nix`, `config.nix`.

## Guidelines

- **NEVER** commit secrets (API keys, passwords) in plain text.
