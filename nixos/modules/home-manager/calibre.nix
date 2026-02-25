{ config, lib, pkgs, ... }:
let
  cfg = config.modules.calibre;
in
{
  options.modules.calibre = with lib; {
    enable = mkEnableOption "calibre";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      calibre
    ];
  };
}
