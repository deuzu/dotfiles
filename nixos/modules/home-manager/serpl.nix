{ config, lib, pkgs, ... }:
let
  cfg = config.modules.serpl;
in
{
  options.modules.serpl = with lib; {
    enable = mkEnableOption "serpl";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      serpl
    ];
  };
}
