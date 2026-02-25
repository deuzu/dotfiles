{ inputs, lib, pkgs, config, ... }:
let
  cfg = config.modules.display.niri;
  bar = lib.getExe pkgs.waybar;
  bluetoothManager = "blueman-applet";
  networkManager = "nm-applet";
  dim = lib.getExe pkgs.hyprdim;
  # launcher = "pidof wofi || wofi --show drun";
  # lock = "${lib.getExe pkgs.hyprlock} --immediate";
  # suspend = "systemctl suspend";
  # terminal = lib.getExe pkgs.ghostty;
  terminal = "wezterm";
  # fileManager = "${terminal} --initial-command=${lib.getExe pkgs.yazi}";
  # brightnessUp = "${lib.getExe pkgs.brightnessctl} set +10%";
  # brightnessDown = "${lib.getExe pkgs.brightnessctl} set 10%-";
  # screenshotFullScreen = "${lib.getExe pkgs.grimblast} --notify copy output";
  # screenshotArea = "${lib.getExe pkgs.grimblast} --notify --freeze copy area";
  # screenshotActive = "${lib.getExe pkgs.grimblast} --notify copy active";
in
{
  imports = [ inputs.niri.homeModules.niri ];

  options.modules.display.niri = with lib; {
    enable = mkEnableOption "Niri";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blueman
      brightnessctl
      # hyprdim
      # grimblast
      networkmanagerapplet
      wev
      wl-clipboard
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    programs.niri = {
      enable = true;

      settings = {
        spawn-at-startup = [
          { command = [ bar ]; }
          { command = [ bluetoothManager ]; }
          { command = [ networkManager ]; }
          { command = [ dim ]; }
        ];

        binds = with config.lib.niri.actions; {
          # "Mod+Space".action.spawn-sh = launcher;
          # "Mod+Space".action.spawn = [
          #   "${pkgs.wofi}/bin/wofi"
          #   "--show drun"
          # ];
          "Mod+Space".action.spawn = lib.getExe pkgs.fuzzel;
          "Mod+T".action.spawn = terminal;
          # "Mod+L".action.spawn = lock;
          "Mod+L".action.spawn = [ "${lib.getExe pkgs.hyprlock}" "--immediate" ];
          # "Mod+E".action.spawn-sh = fileManager;
          "Mod+E".action.spawn = [ "${terminal}" "--initial-command=${lib.getExe pkgs.yazi}" ];
          # "Mod+K".action.spawn-sh = brightnessUp;
          # "Mod+V".action.spawn-sh = brightnessDown;
          "Mod+K".action.spawn = [ "${lib.getExe pkgs.brightnessctl}" "set" "+10%" ];
          "Mod+V".action.spawn = [ "${lib.getExe pkgs.brightnessctl}" "set" "10%-" ];
          # "Mod+Alt+S".action.spawn-sh = suspend;
          "Mod+Alt+S".action.spawn = [ "systemctl" "suspend" ];

          "Print".action.spawn = [ "${lib.getExe pkgs.grimblast}" "--notify" "copy" "output" ];
          "Ctrl+Print".action.spawn = [ "${lib.getExe pkgs.grimblast}" "--notify" "--freeze" "copy" "area" ];
          "Alt+Print".action.spawn = [ "${lib.getExe pkgs.grimblast}" "--notify" "copy" "active" ];

          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;

          "Mod+Alt+Down".action = consume-window-into-column;
          "Mod+Alt+Right".action = expel-window-from-column;

          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Down".action = move-window-down;
          "Mod+Shift+Up".action = move-window-up;
          "Mod+Shift+Right".action = move-column-right;

          "Mod+Ctrl+Left".action = focus-column-left;
          "Mod+Ctrl+Right".action = focus-column-right;
          "Mod+Ctrl+Up".action = focus-workspace-up;
          "Mod+Ctrl+Down".action = focus-workspace-down;
        };
      };
    };
  };
}
