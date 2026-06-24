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

      settings = {
        showBattery = true;
        showWeather = false;
        weatherEnabled = false;
        showClipboard = true;
        controlCenterShowVpnIcon = true;

        acMonitorTimeout = 300;
        acLockTimeout = 360;
        acSuspendTimeout = 0;
        acSuspendBehavior = 2;
        acProfileName = "";
        batteryMonitorTimeout = 300;
        batteryLockTimeout = 360;
        batterySuspendTimeout = 0;
        batterySuspendBehavior = 0;
        batteryProfileName = "";
        batteryChargeLimit = 100;
        lockBeforeSuspend = true;
        loginctlLockIntegration = true;
        fadeToLockEnabled = true;
        fadeToLockGracePeriod = 5;
        fadeToDpmsEnabled = true;
        fadeToDpmsGracePeriod = 5;

        lockScreenShowPowerActions = true;
        lockScreenShowSystemIcons = false;
        lockScreenShowTime = true;
        lockScreenShowDate = true;
        lockScreenShowProfileImage = false;
        lockScreenShowPasswordField = false;
        lockScreenShowMediaPlayer = false;
        lockScreenPowerOffMonitorsOnLock = false;

        controlCenterWidgets = [
          {
            id = "volumeSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "brightnessSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "wifi";
            enabled = true;
            width = 50;
          }
          {
            id = "bluetooth";
            enabled = true;
            width = 50;
          }
          {
            id = "builtin_vpn";
            enabled = true;
            width = 100;
          }
          {
            id = "audioOutput";
            enabled = true;
            width = 50;
          }
          {
            id = "audioInput";
            enabled = true;
            width = 50;
          }
          {
            id = "nightMode";
            enabled = true;
            width = 50;
          }
          {
            id = "darkMode";
            enabled = true;
            width = 50;
          }
        ];

        "barConfigs" = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 0;
            screenPreferences = [
              "all"
            ];
            showOnLastDisplay = true;
            leftWidgets = [
              "workspaceSwitcher"
              "systemTray"
            ];
            centerWidgets = [
              "music"
              "clock"
            ];
            rightWidgets = [
              "dockerManager"
              "dankDiskUsage"
              "cpuUsage"
              "battery"
              "controlCenterButton"
            ];
            spacing = 4;
            innerPadding = 4;
            bottomGap = 0;
            transparency = 1;
            widgetTransparency = 1;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = false;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            borderEnabled = false;
            borderColor = "surfaceText";
            borderOpacity = 1;
            borderThickness = 1;
            fontScale = 1;
            autoHide = false;
            autoHideDelay = 250;
            openOnOverview = false;
            visible = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
          }
        ];
      };

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
      package = pkgs.niri-unstable;
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

        binds = with config.lib.niri.actions; let
          dms-ipc = spawn "dms" "ipc";
        in
        {
          "Mod+Shift+Slash".action.show-hotkey-overlay = { };
          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
          "Alt+Print".action.screenshot-window = { };

          "Mod+L" = {
            hotkey-overlay.title = "Toggle Lock Screen";
            action = dms-ipc "lock" "lock";
          };

          "Mod+M" = {
            hotkey-overlay.title = "Toggle Process List";
            action = dms-ipc "processlist" "toggle";
          };

          "Mod+Space" = {
            hotkey-overlay.title = "Toggle Application Launcher";
            action = dms-ipc "spotlight" "toggle";
          };

          "Mod+X" = {
            hotkey-overlay.title = "Toggle Power Menu";
            action = dms-ipc "powermenu" "toggle";
          };

          "Mod+V" = {
            hotkey-overlay.title = "Toggle Clipboard Manager";
            action = dms-ipc "clipboard" "toggle";
          };

          "Mod+N" = {
            hotkey-overlay.title = "Toggle Notification Center";
            action = dms-ipc "notifications" "toggle";
          };

          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action = dms-ipc "audio" "decrement" "3";
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action = dms-ipc "audio" "micmute";
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action = dms-ipc "audio" "mute";
          };
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action = dms-ipc "audio" "increment" "3";
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [ "dms" "ipc" "call" "brightness" "decrement" "10" "" ];
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [ "dms" "ipc" "call" "brightness" "increment" "10" "" ];
          };

          "Mod+E".action.toggle-overview = { };
          "Mod+Q".action.close-window = { };
          "Mod+F".action.maximize-window-to-edges = { };
          "Mod+Shift+F".action.maximize-column = { };
          "Mod+Alt+F".action.fullscreen-window = { };
          "Mod+Left".action.set-column-width = "-10%";
          "Mod+Right".action.set-column-width = "+10%";
          "Mod+Down".action.set-window-height = "-10%";
          "Mod+Up".action.set-window-height = "+10%";

          "Mod+Alt+Down".action.consume-window-into-column = { };
          "Mod+Alt+Right".action.expel-window-from-column = { };

          "Mod+Shift+Left".action.move-column-left = { };
          "Mod+Shift+Down".action.move-window-down = { };
          "Mod+Shift+Up".action.move-window-up = { };
          "Mod+Shift+Right".action.move-column-right = { };

          "Mod+Ctrl+Left".action.focus-column-left = { };
          "Mod+Ctrl+Right".action.focus-column-right = { };
          "Mod+Ctrl+Up".action.focus-workspace-up = { };
          "Mod+Ctrl+Down".action.focus-workspace-down = { };

          "Mod+Ctrl+Home".action.focus-column-first = { };
          "Mod+Ctrl+End".action.focus-column-last = { };
        };

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

        window-rules = [
          # {
          #   open-maximized-to-edges = true;
          #   popups = {
          #     background-effect = {
          #       blur = true;
          #     };
          #   };
          # }
          {
            matches = [
              { app-id = "zen-beta"; }
              { app-id = "chromium-browser"; }
            ];
            open-on-workspace = "${config.programs.niri.settings.workspaces.w1-browser.name}";
          }
          {
            matches = [
              { app-id = "com.mitchellh.ghostty"; }
              { app-id = "org.wezfurlong.wezterm"; }
            ];
            open-on-workspace = "${config.programs.niri.settings.workspaces.w2-term.name}";
            open-focused = false;
          }
          {
            matches = [
              { app-id = "slack"; }
              { app-id = "signal"; }
            ];
            open-on-workspace = "${config.programs.niri.settings.workspaces.w3-chat.name}";
            open-focused = false;
            block-out-from = "screencast";
          }
          {
            matches = [
              { app-id = "obsidian"; }
            ];
            open-on-workspace = "${config.programs.niri.settings.workspaces.w4-note.name}";
            open-focused = false;
          }
        ];

        spawn-at-startup = [
          { command = [ "zen-beta" ]; }
          { command = [ "wezterm" "start" "--always-new-process" ]; }
          { command = [ "slack" ]; }
          { command = [ "signal-desktop" ]; }
          { command = [ "obsidian" ]; }
        ];
      };
    };
  };
}
