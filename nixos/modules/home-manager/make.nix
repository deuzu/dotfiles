{ config, lib, pkgs, ... }:
let
  cfg = config.modules.make;
in
{
  options.modules.make = with lib; {
    enable = mkEnableOption "Make";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnumake
    ];
  };
}
