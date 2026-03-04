{ ... }:
{
  programs.agent-skills = {
    enable = true;

    sources = {
      my = {
        path = ./skills;
      };
      # anthropic = {
      #   input = "anthropic-skills";
      #   subdir = "skills";
      # };
    };

    skills.enable = [ "slack-gif-creator" "talk-generator" "adr-generator" ];
    targets.agents.enable = true;
  };
}
