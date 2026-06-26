{ config, ... }:
[
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
]
