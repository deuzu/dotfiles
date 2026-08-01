{ lib, config, ... }:
let
  cfg = config.modules.power-management;
in
{
  options.modules.power-management = with lib; {
    enable = mkEnableOption "Power Management";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
  };
}
