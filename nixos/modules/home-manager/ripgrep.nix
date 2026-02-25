{ config, lib, pkgs, ... }:
let
  cfg = config.modules.ripgrep;
in
{
  options.modules.ripgrep = with lib; {
    enable = mkEnableOption "ripgrep";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
}
