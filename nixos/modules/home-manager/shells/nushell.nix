{ config, lib, pkgs, ... }:
let
  cfg = config.modules.shell.nushell;
in
{
  options.modules.shell.nushell = with lib; {
    enable = mkEnableOption "NuShell";

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

    # To switch on bash if needed
    programs.bash = {
      enable = true;
      shellAliases = cfg.aliases;
    };
  };
}
