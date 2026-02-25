{ config, lib, pkgs, ... }:
let
  cfg = config.modules.wget;
in
{
  options.modules.wget = with lib; {
    enable = mkEnableOption "wget";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wget
    ];
  };
}
