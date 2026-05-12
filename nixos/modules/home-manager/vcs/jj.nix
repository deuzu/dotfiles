{ pkgs, config, lib, ... }:
let
  cfg = config.modules.vcs.jujutsu;
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
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = cfg.userEmail;
          name = cfg.userName;
        };
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
        ui = {
          pager = "${pkgs.delta}/bin/delta";
        };
      };
    };
  };
}
