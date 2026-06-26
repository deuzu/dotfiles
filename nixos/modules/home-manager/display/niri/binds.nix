{ config, ... }:

let
  dms-ipc = config.lib.niri.actions.spawn "dms" "ipc";
in
{
  "Mod+Shift+Slash".action.show-hotkey-overlay = { };

  "Mod+Space" = {
    hotkey-overlay.title = "Toggle Application Launcher";
    action = dms-ipc "spotlight" "toggle";
  };

  "Mod+X" = {
    hotkey-overlay.title = "Toggle Power Menu";
    action = dms-ipc "powermenu" "toggle";
  };

  "Mod+L" = {
    hotkey-overlay.title = "Toggle Lock Screen";
    action = dms-ipc "lock" "lock";
  };

  "Mod+M" = {
    hotkey-overlay.title = "Toggle Process List";
    action = dms-ipc "processlist" "toggle";
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

  # Windows Management
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

  # Screeshot
  "Print".action.screenshot = { };
  "Ctrl+Print".action.screenshot-screen = { };
  "Alt+Print".action.screenshot-window = { };
}
