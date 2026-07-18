{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.modules.browser.zen;
in
{
  options.modules.browser.zen = with lib; {
    enable = mkEnableOption "Zen Internet Browser";
    containers = mkOption {
      type = types.attrs;
      default = { };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
    policies = mkOption {
      type = types.attrs;
      default = { };
    };
    spaces = mkOption {
      type = types.attrs;
      default = { };
    };
    search = mkOption {
      type = types.attrs;
      default = { };
    };
    pins = mkOption {
      type = types.attrs;
      default = { };
    };
    mods = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  # https://github.com/luisnquin/nixos-config/tree/main/home/modules/programs/browser/zen
  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];
      policies = cfg.policies;
      profiles.default = {
        name = "Default";
        isDefault = true;
        containers = cfg.containers;
        spacesForce = true;
        spaces = cfg.spaces;
        search = cfg.search;
        settings = cfg.settings;
        pins = cfg.pins;
        mods = cfg.mods;
        # keyboardShortcuts = [];
      };
    };

    stylix.targets.zen-browser.profileNames = lib.mkIf config.modules.browser.zen.enable [ "default" ];
  };
}
