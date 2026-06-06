{ config, lib, ... }:
let
  cfg = config.modules.vcs.jujutsu;
  gitCfg = config.modules.vcs.git;
in
{
  options.modules.vcs.jujutsu = with lib; {
    enable = mkEnableOption "Jujutsu VCS";
    userName = mkOption {
      type = types.str;
    };
    userEmail = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user = {
            email = cfg.userEmail;
            name = cfg.userName;
          };
          ui.default-command = "status";
          aliases = {
            n = "new";
            d = "describe -m";
          };
          signing = {
            backend = "gpg";
            behavior = "own";
          };
          git = {
            sign-on-push = true;
          };
        };
      };
      delta.enableJujutsuIntegration = true;
      git.ignores = lib.mkIf gitCfg.enable [ ".jj*" ];
    };
  };
}
