# AGENTS.md

## Repository Overview

This repository manages two **independent** concerns:

- **NixOS system configuration** for personal machines (Flakes + Home Manager) — in `nixos/`.
- **Custom QMK keyboard firmware** for split keyboards — in `keyboards/`.

The two trees are intentionally decoupled: `keyboards/` is never imported by `flake.nix` or any NixOS module.

## Directory Map

- `nixos/`: NixOS + Home Manager configuration. See [`nixos/AGENTS.md`](nixos/AGENTS.md).
- `keyboards/`: QMK firmware source (Cantor, Piantor). See [`keyboards/AGENTS.md`](keyboards/AGENTS.md).
- `.github/workflows/keyboards.yaml`: CI that builds keyboard firmware on push.
- `.sops.yaml`: SOPS age-key config (read by `sops-nix`).
- `.gitattributes`: `git-crypt` filter rules for legacy secret patterns.

## Routing

Before working, **read the AGENTS.md matching the directory you are editing**. Topic-based routing:

| Context / Task | Read |
| --- | --- |
| Editing QMK keymaps, `keymap.c`, `config.h`, `rules.mk` | [`keyboards/AGENTS.md`](keyboards/AGENTS.md) |
| Building / validating keyboard firmware | [`keyboards/AGENTS.md`](keyboards/AGENTS.md) |
| Adding a NixOS / Home Manager package | [`nixos/AGENTS.md`](nixos/AGENTS.md) |
| Creating or modifying a system / user module | [`nixos/AGENTS.md`](nixos/AGENTS.md) |
| Defining or editing a host (`hosts/<host>/`) | [`nixos/AGENTS.md`](nixos/AGENTS.md) |
| Managing secrets (`sops-nix` or `git-crypt`) | [`nixos/AGENTS.md`](nixos/AGENTS.md) |
| Updating flake inputs / `flake.nix` / `flake.lock` | [`nixos/AGENTS.md`](nixos/AGENTS.md) |
| Rebuilding / validating NixOS (`nixos-rebuild`, `nix flake check`) | [`nixos/AGENTS.md`](nixos/AGENTS.md) |

## Cross-Cutting Rules

- **DO** keep NixOS and QMK changes in their respective trees; never mix them.
- **DON'T** reference `keyboards/` from `nixos/` (or vice versa).
- **NEVER** commit secrets in plain text — see the "Managing Secrets" section of [`nixos/AGENTS.md`](nixos/AGENTS.md).
