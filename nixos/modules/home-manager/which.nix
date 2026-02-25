{ config, lib, pkgs, ... }:
let
  cfg = config.modules.which;
in
{
  options.modules.which = with lib; {
    enable = mkEnableOption "which";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      which
    ];
  };
}
