{ config, lib, pkgs, ... }:
let
  cfg = config.modules.gh;
in
{
  options.modules.gh = with lib; {
    enable = mkEnableOption "Github CLI Tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
    ];
  };
}
