{ lib, config, ... }:

let
  cfg = config.modules.gnome-keyring;
in
{
  options.modules.gnome-keyring = with lib; {
    enable = mkEnableOption "gnome-keyring";
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
      hyprland.enableGnomeKeyring = true;
      niri.enableGnomeKeyring = true;
    };
  };
}
