{ config, lib, ... }:
let
  cfg = config.modules.shells.bash;
in
{
  options.modules.shells.bash = with lib; {
    enable = mkEnableOption "Bash Shell";

    isDefault = mkEnableOption "Is the default shell";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = cfg.aliases;
    };

    programs = {
      carapace.enableBashIntegration = true;
      direnv.enableBashIntegration = true;
      starship.enableBashIntegration = true;
      yazi.enableBashIntegration = true;
      # zellij.enableBashIntegration = cfg.isDefault;
      ghostty.enableBashIntegration = cfg.isDefault;
      wezterm.enableBashIntegration = cfg.isDefault;
    };
  };
}
