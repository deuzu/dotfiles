{ config, lib, pkgs, ... }:
let
  cfg = config.modules.agent-browser;
in
{
  options.modules.agent-browser = with lib; {
    enable = mkEnableOption "agent-browser (headless browser automation CLI for AI agents)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      agent-browser
    ];
  };
}
