{ config, lib, pkgs, ... }:
let
  cfg = config.modules.httpie;
in
{
  options.modules.httpie = with lib; {
    enable = mkEnableOption "HTTPie";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      httpie
    ];
  };
}
