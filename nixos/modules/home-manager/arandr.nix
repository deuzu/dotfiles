{ config, lib, pkgs, ... }:
let
  cfg = config.modules.arandr;
in
{
  options.modules.arandr = with lib; {
    enable = mkEnableOption "Arandr";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      arandr
    ];
  };
}
