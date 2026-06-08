{ config, lib, pkgs, ... }:
let
  cfg = config.modules.wl-kbptr;
in
{
  options.modules.wl-kbptr.enable = lib.mkEnableOption "wl-kbptr";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-kbptr
    ];
  };
}
