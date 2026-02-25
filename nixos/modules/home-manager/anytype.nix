{ config, lib, pkgs, ... }:
let
  cfg = config.modules.anytype;
in
{
  options.modules.anytype = with lib; {
    enable = mkEnableOption "Anytype";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      anytype
    ];
  };
}
