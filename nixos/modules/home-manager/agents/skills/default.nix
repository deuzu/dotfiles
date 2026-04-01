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

    skills.enable = [
      # "slack-gif-creator"
      # "adr-generator"
      "github-code-search"
    ];
    targets.agents.enable = true;
  };
}
