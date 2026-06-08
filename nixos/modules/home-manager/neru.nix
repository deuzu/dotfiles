{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neru;
in
{
  options.modules.neru = {
    enable = lib.mkEnableOption "neru";
  };

  config = lib.mkIf cfg.enable {
    services.neru = {
      enable = true;
      config = ''
        [hotkeys]
        "Primary+Shift+Space" = "hints left_click"
        "Primary+Shift+G" = "grid left_click"

        [general]
        excluded_apps = ["com.apple.Terminal"]
      '';
    };
  };
}
