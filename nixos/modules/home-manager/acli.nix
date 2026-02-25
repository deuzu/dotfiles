{ config, lib, pkgs, ... }:
let
  cfg = config.modules.acli;
in
{
  options.modules.acli = with lib; {
    enable = mkEnableOption "Atlassian CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      acli
    ];
  };
}
