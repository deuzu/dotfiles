{ config, lib, pkgs, ... }:
let
  cfg = config.modules.libreoffice;
in
{
  options.modules.libreoffice = with lib; {
    enable = mkEnableOption "Libreoffice";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice
    ];
  };
}
