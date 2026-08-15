{ inputs, lib, pkgs, config, ... }:
let
  cfg = config.modules.display.niri;
in
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.homeModules.default
    inputs.dms.homeModules.niri
  ];

  options.modules.display.niri = with lib; {
    enable = mkEnableOption "Niri";
    spawnAtStartup = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of commands to spawn at startup";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      XDG_CURRENT_DESKTOP = "niri";
      GDK_BACKEND = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    programs.dank-material-shell = {
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enable = true;
      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      plugins = {
        dankBatteryAlerts.enable = true;
        calculator.enable = true;
        dockerManager.enable = true;
        nixPackageRunner.enable = true;
        dankDiskUsage.enable = true;
        emojiLauncher.enable = true;
      };

      settings = import ./dms-settings.nix;

      niri = {
        enableKeybinds = false;
        includes = {
          enable = true;
          filesToInclude = [
            "alttab"
            "binds"
            "outputs"
            "wpblur"
          ];
        };
      };
    };

    programs.niri = {
      enable = true;
      package = pkgs.niri;
      settings = {
        input = {
          keyboard.xkb = {
            layout = "us";
            variant = "intl";
          };
          focus-follows-mouse.enable = true;
          warp-mouse-to-focus.enable = true;
          mouse.accel-profile = "flat";
        };

        hotkey-overlay.skip-at-startup = true;

        binds = import ./binds.nix { inherit config; };

        layout = {
          gaps = 0;
          border.enable = false;
          focus-ring.enable = false;
        };

        workspaces = {
          "w1-browser" = { name = "1"; };
          "w2-term" = { name = "2"; };
          "w3-chat" = { name = "3"; };
          "w4-note" = { name = "4"; };
        };

        window-rules = import ./window-rules.nix { inherit config; };

        spawn-at-startup = map (cmd: { command = lib.splitString " " cmd; }) cfg.spawnAtStartup;
      };
    };
  };
}
