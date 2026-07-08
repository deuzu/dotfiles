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

    bashScripts = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Bash scripts/functions to inject into bash";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = cfg.aliases;
      initExtra = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: body: ''
        ${name}() {
          ${body}
        }
      '') cfg.bashScripts);
    };
  };
}
