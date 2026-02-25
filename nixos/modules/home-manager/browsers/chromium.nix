{ config, lib, ... }:
let
  cfg = config.modules.browser.chromium;
in
{
  options.modules.browser.chromium = with lib; {
    enable = mkEnableOption "̃Chromium Internet Browser";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
    };
  };
}
