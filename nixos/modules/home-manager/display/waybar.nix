{ config, lib, pkgs, ... }:
let
  cfg = config.modules.display.waybar;
  # terminalWithCommand = "${lib.getExe pkgs.ghostty} --initial-command=";
  terminalWithCommand = "wezterm start -- ";
  soundControl = "${lib.getExe pkgs.pavucontrol}";
in
{
  options.modules.display.waybar = with lib; {
    enable = mkEnableOption "Waybar";
  };

  config = lib.mkIf cfg.enable {
    stylix.targets.waybar.addCss = false;

    programs.waybar = {
      enable = true;
      settings = {
        main = {
          spacing = 6;
          modules-left = [ "tray" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "pulseaudio" "bluetooth" "network" "battery" "clock#time" "clock#date" ];
          tray = {
            spacing = 10;
          };
          "hyprland/workspaces" = {
            "format" = "{icon}";
            "format-icons" = {
              "active" = "";
              "default" = "";
              "empty" = "";
            };
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}% ";
            format-alt = "{icon} {time}";
            format-icons = [
              " "
              " "
              " "
              " "
              " "
            ];
          };
          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "${terminalWithCommand}blueman-applet";
          };
          "clock#time" = {
            "interval" = 5;
            "format" = "{:%H:%M}";
            "tooltip" = false;
          };
          "clock#date" = {
            interval = 10;
            format = "{:%e %b}";
            tooltip-format = "{:%e %B %Y}";
          };
          network = {
            interval = 5;
            format-wifi = "";
            format-ethernet = " {ifname}";
            format-disconnected = " Disconnected";
            tooltip-format = "{ifname}: {ipaddr}";
            tooltip-format-wifi = "{essid} {signalStrength}%";
            tooltip-format-ethernet = "{ipaddr}/{cidr}";
            on-click = "${terminalWithCommand}nm-applet";
          };
          pulseaudio = {
            scroll-step = 1;
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" ];
            };
            on-click = "${soundControl}";
          };
        };
      };
      style = lib.mkAfter (builtins.readFile ./waybar-style.css);
    };
  };
}
