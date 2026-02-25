{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev.nodejs;
in
{
  options.modules.dev.nodejs = with lib; {
    enable = mkEnableOption "NodeJS";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_25
    ];
  };
}
