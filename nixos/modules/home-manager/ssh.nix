{ config, lib, ... }:
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = with lib; {
    enable = mkEnableOption "SSH";
    keys = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };
          public = mkOption {
            type = types.str;
          };
          private = mkOption {
            type = types.str;
          };
        };
      });
      default = [ ];
    };
    matchBlocks = mkOption {
      type = types.attrs;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = cfg.matchBlocks;
    };

    services.ssh-agent.enable = true;

    home.file =
      builtins.listToAttrs (
        builtins.concatLists (
          map
            (key:
              let
                keySourceFilePub = "${key.name}_source.pub";
                keyFilePub = "${key.name}.pub";
                keySourceFile = "${key.name}_source";
                keyFile = "${key.name}";
              in
              [
                {
                  name = ".ssh/${keySourceFilePub}";
                  value = {
                    text = key.public;
                    onChange = "cat ~/.ssh/${keySourceFilePub} > ~/.ssh/${keyFilePub} && chmod 600 ~/.ssh/${keyFilePub}";
                  };
                }
                {
                  name = ".ssh/${keySourceFile}";
                  value = {
                    text = key.private;
                    onChange = "cat ~/.ssh/${keySourceFile} > ~/.ssh/${keyFile} && chmod 600 ~/.ssh/${keyFile}";
                  };
                }
              ]
            )
            cfg.keys
        )
      );
  };
}
