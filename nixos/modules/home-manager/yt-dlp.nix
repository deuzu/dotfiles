{ config, lib, pkgs, ... }:
let
  cfg = config.modules.yt-dlp;
in
{
  options.modules.yt-dlp = with lib; {
    enable = mkEnableOption "yt-dlp";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      yt-dlp
    ];
  };
}
