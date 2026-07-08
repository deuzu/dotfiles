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

    bashScripts = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Bash scripts/functions to expose via bash -c in Nushell";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      shellAliases = cfg.aliases;
      settings = {
        show_banner = false;
      };
      extraConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: body: ''
        def --wrapped ${name} [...args] {
          ^bash -c `
            ${body}
          ` _ ...$args
        }
      '') cfg.bashScripts);
    };

    # To switch on bash if needed
    programs.bash = {
      enable = true;
      shellAliases = cfg.aliases;
    };
  };
}
