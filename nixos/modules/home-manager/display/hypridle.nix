{ config, lib, ... }:
let
  cfg = config.modules.display.hypridle;
in
{
  options.modules.display.hypridle = with lib; {
    enable = mkEnableOption "Hypridle";
  };

  config = lib.mkIf cfg.enable {

    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl --save set 10";
            on-resume = "brightnessctl --restore";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 380;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 43200; # 12h
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
