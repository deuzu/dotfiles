{ config, lib, pkgs, ... }:
let
  cfg = config.modules.jq;
in
{
  options.modules.jq = with lib; {
    enable = mkEnableOption "jq";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jq
      jaq
    ];
  };
}
