{ config, lib, pkgs, ... }:
let
  cfg = config.modules.whisper;
in
{
  options.modules.whisper = with lib; {
    enable = mkEnableOption "whisper";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      openai-whisper
      ffmpeg
    ];
  };
}
