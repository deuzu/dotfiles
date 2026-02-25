{ config, lib, ... }:
let
  cfg = config.modules.browser.firefox;
in
{
  options.modules.browser.firefox = with lib; {
    enable = mkEnableOption "Firefox Internet Browser";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
    };
  };
}
