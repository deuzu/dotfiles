{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.dive;
in
{
  options.modules.devops.dive = with lib; {
    enable = mkEnableOption "dive Docker Images Explorer";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      dive
    ];
  };
}
