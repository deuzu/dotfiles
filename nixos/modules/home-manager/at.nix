{ config, lib, pkgs, ... }:
let
  cfg = config.modules.at;
in
{
  options.modules.at = with lib; {
    enable = mkEnableOption "at";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      at
    ];
  };
}
