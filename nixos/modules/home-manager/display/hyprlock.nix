{ config, lib, ... }:
let
  cfg = config.modules.display.hyprlock;
in
{
  options.modules.display.hyprlock = with lib; {
    enable = mkEnableOption "Hyprlock";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;

      settings = {
        hide_cursor = true;
      };
    };
  };
}
