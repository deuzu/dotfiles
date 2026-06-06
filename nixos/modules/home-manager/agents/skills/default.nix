{ pkgs, ... }:
{
  programs.agent-skills = {
    enable = true;

    sources = {
      my = {
        path = ./skills;
        filter.maxDepth = 1;
      };
      # anthropic = {
      #   input = "anthropic-skills";
      #   subdir = "skills";
      # };
    };

    skills = {
      enable = [
        # "slack-gif-creator"
        # "adr-generator"
        "github-code-search"
      ];
      explicit = {
        # git clone https://github.com/coleam00/excalidraw-diagram-skill excalidraw-diagram" && rm excalidraw-diagram/.git -rf
        # excalidraw-diagram = {
        #   from = "my";
        #   path = "excalidraw-diagram";
        #   packages = with pkgs; [
        #     (python3.withPackages (
        #       python-pkgs: with python-pkgs; [
        #       ]
        #     ))
        #     uv
        #     playwright
        #     playwright-driver.browsers-chromium
        #     ungoogled-chromium
        #   ];
        # };
      };
    };
    targets.agents.enable = true;
  };
}
