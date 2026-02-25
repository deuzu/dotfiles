{ config, lib, ... }:
let
  cfg = config.modules.display.dunst;
in
{
  options.modules.display.dunst = with lib; {
    enable = mkEnableOption "Dunst";
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
  };
}
