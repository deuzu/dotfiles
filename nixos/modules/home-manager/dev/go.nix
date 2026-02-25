{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev.golang;
in
{
  options.modules.dev.golang = with lib; {
    enable = mkEnableOption "Golang";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      go
    ];
  };
}
