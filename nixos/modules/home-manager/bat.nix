{ config, lib, pkgs, ... }:
let
  cfg = config.modules.bat;
in
{
  options.modules.bat = with lib; {
    enable = mkEnableOption "Bat";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
    ];
  };
}
