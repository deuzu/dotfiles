{ lib, config, pkgs, ... }:

let
  cfg = config.modules.tuigreet;
  greeter = lib.getExe pkgs.tuigreet;
in
{
  options.modules.tuigreet = with lib; {
    enable = mkEnableOption "tuigreet";
    # command = mkOption {
    #   type = lib.types.str;
    # };
    username = mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;
    # programs.regreet.enable = true;

    services = {
      xserver.enable = false;
      displayManager.gdm.enable = false;
      desktopManager.gnome.enable = false;
      gnome.gnome-keyring.enable = true;
      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            # command = "${greeter} --asterisks --remember --remember-user-session --time --cmd niri-session";
            # command = "${greeter} --asterisks --remember --remember-user-session --time --cmd ${cfg.command}";
            command = "${greeter} --asterisks --remember --time --cmd hyprland";
            user = "${cfg.username}";
          };
          default_session = initial_session;
        };
      };
    };

    security.pam.services = {
      hyprland.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
    };
  };
}
