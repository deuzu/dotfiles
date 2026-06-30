{ config, lib, ... }:
let
  cfg = config.modules.shell.bash;
in
{
  options.modules.shell.bash = with lib; {
    enable = mkEnableOption "Bash Shell";

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
  };
}
