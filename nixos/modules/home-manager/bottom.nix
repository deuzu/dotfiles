{ config, lib, pkgs, ... }:
let
  cfg = config.modules.bottom;
in
{
  options.modules.bottom = with lib; {
    enable = mkEnableOption "bottom";
  };

  config = lib.mkIf cfg.enable {
    programs.bottom = {
      enable = true;
    };
  };
}
