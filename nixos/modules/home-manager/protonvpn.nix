{ config, lib, pkgs, ... }:
let
  cfg = config.modules.protonvpn;
in
{
  options.modules.protonvpn = with lib; {
    enable = mkEnableOption "protonvpn";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      proton-vpn
    ];
  };
}
