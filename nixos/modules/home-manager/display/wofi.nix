{ config, lib, ... }:
let
  cfg = config.modules.display.wofi;
in
{
  options.modules.display.wofi = with lib; {
    enable = mkEnableOption "Wofi";
  };

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
    };
  };
}
