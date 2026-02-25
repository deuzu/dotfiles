{ config, lib, pkgs, ... }:
let
  cfg = config.modules.shells.nushell;
in
{
  options.modules.shells.nushell = with lib; {
    enable = mkEnableOption "NuShell";

    isDefault = mkEnableOption "Is the default shell";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      shellAliases = cfg.aliases;
      settings = {
        show_banner = false;
      };
    };

    programs = {
      atuin.enableNushellIntegration = true;
      carapace.enableNushellIntegration = true;
      direnv.enableNushellIntegration = true;
      starship.enableNushellIntegration = true;
      yazi.enableNushellIntegration = true;
      # zellij.enableNushellIntegration = cfg.isDefault;
      zellij.settings.default_shell = lib.mkIf cfg.isDefault(lib.getExe pkgs.nushell);
      # ghostty.enableNushellIntegration = cfg.isDefault;
      ghostty.settings.command = lib.mkIf cfg.isDefault(lib.getExe pkgs.nushell);
      # wezterm.enableNushellIntegration = cfg.isDefault;
    };
  };
}
