{ lib, config, pkgs, ... }:

let
  cfg = config.modules.tuigreet;
  greeter = lib.getExe pkgs.tuigreet;
in
{
  options.modules.tuigreet = with lib; {
    enable = mkEnableOption "tuigreet";
    command = mkOption {
      type = lib.types.str;
    };
    username = mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver.enable = false;
      displayManager.gdm.enable = false;
      desktopManager.gnome.enable = false;
      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${greeter} --asterisks --remember --remember-user-session --time --cmd ${cfg.command}";
            user = "${cfg.username}";
          };
          default_session = initial_session;
        };
      };
    };
  };
}
