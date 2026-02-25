{ config, lib, pkgs, ... }:
let
  cfg = config.modules.signal;
in
{
  options.modules.signal = with lib; {
    enable = mkEnableOption "signal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}
