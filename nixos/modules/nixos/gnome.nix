{ lib, config, ... }:
let
  cfg = config.modules.gnome;
in
{
  options.modules.gnome = with lib; {
    enable = mkEnableOption "Gnome Display Manager";
  };

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
