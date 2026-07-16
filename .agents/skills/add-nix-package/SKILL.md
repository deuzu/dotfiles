---
name: add-nix-package
description: Add a Nix package to the system or user environment. Use when asked to install, add, or configure a new package or application.
---
# Adding a Nix Package

Follow these steps to add a new package:

1. **Identify the Scope, Host & User**:
   - Determine the target hostname (e.g., `workstation`, `home-wsl`) where the package should be installed.
   - Determine if the package should be installed system-wide or for a specific user. If user-specific, identify the target user from the context or ask the user.
   - **System-wide**: Use `environment.systemPackages` in a module under `nixos/modules/nixos/`.
   - **User-specific**: Use `home.packages` in a module under `nixos/modules/home-manager/`.

2. **Create or Locate the Module**:
   - For a new package, create a new `.nix` file defining a module within the appropriate directory (e.g., `text-editors/helix.nix`) then export it on the appropriate `default.nix` file.
   - You **MUST** use the custom option pattern for enabling it. 
   - Example module structure:
     ```nix
     { config, lib, pkgs, ... }:
     {
       options.modules.<package_name>.enable = lib.mkEnableOption "Enable <package_name>";
       config = lib.mkIf config.modules.<package_name>.enable {
         home.packages = with pkgs; [ <package_name> ]; # Or environment.systemPackages
       };
     }
     ```

3. **Enable the Module**:
   - Ensure the module is imported and enabled in the host configuration (`nixos/hosts/<hostname>/secrets.nix`) or the relevant user configuration (e.g., `nixos/hosts/<hostname>/users/secrets.nix`).
   - Add `modules.<package_name>.enable = true;`.
