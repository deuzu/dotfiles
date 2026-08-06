{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nautilus;
in
{
  options.modules.nautilus = with lib; {
    enable = mkEnableOption "Nautilus";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
    ];
  };
}
