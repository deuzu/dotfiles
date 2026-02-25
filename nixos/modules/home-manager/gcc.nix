{ config, lib, pkgs, ... }:
let
  cfg = config.modules.gcc;
in
{
  options.modules.gcc = with lib; {
    enable = mkEnableOption "gcc";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gcc
    ];
  };
}
