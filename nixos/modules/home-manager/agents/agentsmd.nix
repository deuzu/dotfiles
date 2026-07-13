{ config, lib, ... }:

let
  cfg = config.modules.agents.agentsmd;
in
{
  options.modules.agents.agentsmd = {
    enable = lib.mkEnableOption "AGENTS.md config file";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/agents/AGENTS.md".source = ./AGENTS.md;
  };
}
