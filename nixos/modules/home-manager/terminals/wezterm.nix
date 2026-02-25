{ config, lib, ... }:
let
  cfg = config.modules.terminals.wezterm;
in
{
  options.modules.terminals.wezterm = with lib; {
    enable = mkEnableOption "Wezterm Terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        config.hide_tab_bar_if_only_one_tab = true
        config.window_close_confirmation = 'NeverPrompt'
      '';
    };
  };
}
