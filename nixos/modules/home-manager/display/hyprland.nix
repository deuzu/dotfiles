{ lib, config, pkgs, ... }:
let
  cfg = config.modules.display.hyprland;
  # terminal = lib.getExe pkgs.ghostty;
  terminal = "wezterm";
  terminalMultiplexer = lib.getExe pkgs.zellij;
  # terminalWithMultiplexer = "${terminal} --initial-command=${terminalMultiplexer}";
  terminalWithMultiplexer = "${terminal} -- ${terminalMultiplexer}";
  k9s = lib.getExe pkgs.k9s;
  terminalWithK9s = "${terminal} --initial-command=${k9s}";
  fileManager = "${terminal} --initial-command=${lib.getExe pkgs.yazi}";
  bluetoothManager = "blueman-applet";
  networkManager = "nm-applet";
  launcher = "pidof wofi || ${lib.getExe pkgs.wofi} --show drun";
  lock = "${lib.getExe pkgs.hyprlock} --immediate";
  bar = lib.getExe pkgs.waybar;
  browser = "zen";
  screenshotFullScreen = "${lib.getExe pkgs.grimblast} --notify copy output";
  screenshotArea = "${lib.getExe pkgs.grimblast} --notify --freeze copy area";
  screenshotActive = "${lib.getExe pkgs.grimblast} --notify copy active";
  anytype = lib.getExe pkgs.anytype;
  jq = lib.getExe pkgs.jaq;
  dim = lib.getExe pkgs.hyprdim;
  slack = lib.getExe pkgs.slack;
  brightnessUp = "${lib.getExe pkgs.brightnessctl} set +10%";
  brightnessDown = "${lib.getExe pkgs.brightnessctl} set 10%-";
  suspend = "systemctl suspend";
in
{
  options.modules.display.hyprland = with lib; {
    enable = mkEnableOption "Hyprland";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blueman
      brightnessctl
      hyprdim
      grimblast
      networkmanagerapplet
      wev
      wireplumber
      wl-clipboard
      xdg-desktop-portal-hyprland
    ];

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;

      # plugins = with pkgs.hyprlandPlugins; [
      #   hyprspace
      #   hyprexpo
      # ];

      settings = {
        monitor = [ ",preferred,auto,1,bitdepth,10" ];
        exec-once = [
          "bus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "${bar}"
          "${bluetoothManager}"
          "${networkManager}"
          "${dim}"
          "[workspace 1 silent] ${browser}"
          "[workspace 2 silent] ${terminal}"
          "[workspace 3 silent] ${slack}"
          "[workspace 4 silent] ${anytype}"
          "[workspace 5 silent] ${terminalWithK9s}"
        ];
        bind = [
          "SUPER, space, exec, ${launcher}"
          "SUPER, T, exec, ${terminal}"
          "SUPER ALT, T, exec, ${terminalWithMultiplexer}"
          "SUPER, L, exec, ${lock}"
          "SUPER, E, exec, ${fileManager}"
          "SUPER, K, exec, ${brightnessUp}"
          "SUPER, V, exec, ${brightnessDown}"
          "SUPER ALT, S, exec, ${suspend}"

          # Screenshot
          ", Print, exec, ${screenshotFullScreen}"
          "CTRL, Print, exec, ${screenshotArea} --notify --freeze copy area"
          "ALT, Print, exec, ${screenshotActive} --notify copy active"

          # Window
          "SUPER, Q, killactive"
          "SUPER ALT, Q, exec, kill -9 $(hyprctl -j activewindow | ${jq} -r '.pid')"
          "SUPER, F, fullscreen"
          "ALT, TAB, cyclenext"

          # Workspace
          "SUPER CTRL, LEFT, workspace, e-1"
          "SUPER CTRL, RIGHT, workspace, e+1"
          "SUPER CTRL SHIFT, LEFT, movetoworkspace, e-1"
          "SUPER CTRL SHIFT, RIGHT, movetoworkspace, e+1"
          "SUPER CTRL ALT, LEFT, movecurrentworkspacetomonitor, -1"
          "SUPER CTRL ALT, RIGHT, movecurrentworkspacetomonitor, +1"
          "SUPER CTRL, T, workspace, 1"
          "SUPER CTRL, N, workspace, 2"
          "SUPER CTRL, S, workspace, 3"
          "SUPER CTRL, R, workspace, 4"
          "SUPER CTRL, P, workspace, 5"
          "SUPER CTRL, L, workspace, 6"
          "SUPER CTRL, C, workspace, 7"
          "SUPER CTRL, Q, workspace, 8"
          "SUPER CTRL, D, workspace, 9"
          "SUPER CTRL, M, workspace, 10"
          "SUPER CTRL, W, workspace, 11"
          "SUPER CTRL, X, workspace, 12"
          "SUPER CTRL SHIFT, T, movetoworkspace, 1"
          "SUPER CTRL SHIFT, N, movetoworkspace, 2"
          "SUPER CTRL SHIFT, S, movetoworkspace, 3"
          "SUPER CTRL SHIFT, R, movetoworkspace, 4"
          "SUPER CTRL SHIFT, P, movetoworkspace, 5"
          "SUPER CTRL SHIFT, L, movetoworkspace, 6"
          "SUPER CTRL SHIFT, C, movetoworkspace, 7"
          "SUPER CTRL SHIFT, Q, movetoworkspace, 8"
          "SUPER CTRL SHIFT, D, movetoworkspace, 9"
          "SUPER CTRL SHIFT, M, movetoworkspace, 10"
          "SUPER CTRL SHIFT, W, movetoworkspace, 11"
          "SUPER CTRL SHIFT, X, movetoworkspace, 12"
          "SUPER CTRL ALT, T, focusworkspaceoncurrentmonitor, 1"
          "SUPER CTRL ALT, N, focusworkspaceoncurrentmonitor, 2"
          "SUPER CTRL ALT, S, focusworkspaceoncurrentmonitor, 3"
          "SUPER CTRL ALT, R, focusworkspaceoncurrentmonitor, 4"
          "SUPER CTRL ALT, P, focusworkspaceoncurrentmonitor, 5"
          "SUPER CTRL ALT, L, focusworkspaceoncurrentmonitor, 6"
          "SUPER CTRL ALT, C, focusworkspaceoncurrentmonitor, 7"
          "SUPER CTRL ALT, Q, focusworkspaceoncurrentmonitor, 8"
          "SUPER CTRL ALT, D, focusworkspaceoncurrentmonitor, 9"
          "SUPER CTRL ALT, M, focusworkspaceoncurrentmonitor, 10"
          "SUPER CTRL ALT, W, focusworkspaceoncurrentmonitor, 11"
          "SUPER CTRL ALT, X, focusworkspaceoncurrentmonitor, 12"
          # "SUPER, ESC, hyprexpo:expo, toggle"
          # "SUPER, ESC, overview:toggle, all"
        ];
        general = {
          gaps_in = 0;
          gaps_out = 0;
        };
        input = {
          kb_layout = "us";
          kb_variant = "intl";
        };
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          animate_manual_resizes = true;
        };
        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };
      };
    };
  };
}
