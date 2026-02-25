{ config, lib, pkgs, ... }:
let
  cfg = config.modules.display.gnome;
in
{
  options.modules.display.gnome = with lib; {
    enable = mkEnableOption "Gnome";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      dconf-editor
      dconf2nix
      gnome-tweaks
      smile
    ];

    programs.gnome-shell = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        { package = appindicator; }
        { package = auto-move-windows; }
        { package = system-monitor; }
        { package = smile-complementary-extension; }
      ];
    };

    dconf.settings = {
      # gsettings list-recursively | rg "..."
      "org/gnome/desktop/session" = {
        "logout-delay" = 14400; # 4h
      };
      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [
          "zen.desktop:1"
          "ghostty.desktop:2"
        ];
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        edge-tiling = true;
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/desktop/wm/preferences" = {
        "num-workspaces" = 4;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-left = [ "<Super><Control>Left" ];
        switch-to-workspace-right = [ "<Super><Control>Right" ];
        move-to-workspace-left = [ "<Shift><Control><Super>Left" ];
        move-to-workspace-right = [ "<Shift><Control><Super>Right" ];
        switch-windows = [ "<Alt>Tab" ];
        close = [ "<super>q" "<alt>f4" ];
        toggle-fullscreen = [ "<super>f" ];
        switch-input-source = [ "XF86Keyboard" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = [ "<Super>e" ];
        search = [ "<Super>space" ];
        screensaver = [ "<Super>l" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>B";
        command = "zen";
        name = "Zen Browser";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>T";
        command = "ghostty";
        name = "Terminal";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<Super>period";
        command = "smile";
        name = "Smile";
      };
    };
  };
}
