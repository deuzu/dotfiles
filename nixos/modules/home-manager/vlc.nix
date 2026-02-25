{ config, lib, pkgs, ... }:
let
  cfg = config.modules.vlc;
in
{
  options.modules.vlc = with lib; {
    enable = mkEnableOption "vlc";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
    ];
  };
}
