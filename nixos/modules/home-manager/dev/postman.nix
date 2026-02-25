{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev.postman;
in
{
  options.modules.dev.postman = with lib; {
    enable = mkEnableOption "Postman";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ postman ];
  };
}
