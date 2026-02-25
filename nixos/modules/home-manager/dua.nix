{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dua;
in
{
  options.modules.dua = with lib; {
    enable = mkEnableOption "dua";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      dua
    ];
  };
}
