{ config, lib, pkgs, ... }:
let
  cfg = config.modules.slack;
in
{
  options.modules.slack = with lib; {
    enable = mkEnableOption "Slack";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
    ];
  };
}
