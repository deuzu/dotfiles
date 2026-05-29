{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.modules.agents.gooseCli;
  env = config.modules.env;
  gitEnable = config.modules.vcs.git.enable;
in
{
  options.modules.agents.gooseCli = with lib; {
    enable = mkEnableOption "Goose CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      goose-cli

      (myLib.mkBwrap pkgs {
        name = "aig";
        executable = "${pkgs.goose-cli}/bin/goose";
        bestEffort = true;
        preScripts = ''
          mkdir -p "$HOME/.config/goose"
        '';
        extraRw = [
          "$HOME/.config/goose"
          "$HOME/.local/share/goose"
          "$HOME/.local/state/goose"
          "$HOME/.cache/goose"
        ];
        extraRwx = [
          "/tmp"
          "$PWD"
        ];
        extraEnv = [
          "DBUS_SESSION_BUS_ADDRESS"
          "GOOSE_PROVIDER"
          "GOOSE_MODEL"
          "GOOSE_PLANNER_PROVIDER"
          "GOOSE_PLANNER_MODEL"
          "GOOSE_EDITOR_API_KEY"
          "GOOSE_EDITOR_HOST"
          "GOOSE_EDITOR_MODEL"
        ];
      })
    ];

    home.file = {
      ".config/goose/config.yaml".text = builtins.readFile (pkgs.replaceVars ./config.yaml { });
    } // (myLib.folder pkgs ./recipes ".config/goose/recipes" {
      mainModelProvider = env.GOOSE_PROVIDER;
      mainModel = env.GOOSE_MODEL;
      largeModelProvider = env.GOOSE_PLANNER_PROVIDER;
      largeModel = env.GOOSE_PLANNER_MODEL;
    });

    programs.git = lib.mkIf gitEnable {
      ignores = [
        ".goose/"
        ".gooseignore"
        ".goosehints"
      ];
    };

    /*
    mkdir -p ./nixos/modules/home-manager/goose/recipes/subrecipes
    curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/rpi-research.yaml -o ./nixos/modules/home-manager/goose/recipes/rpi-research.yaml && echo -e "settings:\n  goose_provider: \"@largeModelProvider\"\n  goose_model: \"@largeModel@\"\n  # goose_provider: \"@mainModelProvider@\"\n  # goose_model: \"@mainModel@\"\n" >> ./nixos/modules/home-manager/goose/recipes/rpi-research.yaml
    curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/rpi-plan.yaml -o ./nixos/modules/home-manager/goose/recipes/rpi-plan.yaml  && echo -e "settings:\n  goose_provider: \"@largeModelProvider\"\n  goose_model: \"@largeModel@\"\n  # goose_provider: \"@mainModelProvider@\"\n  # goose_model: \"@mainModel@\"\n" >> ./nixos/modules/home-manager/goose/recipes/rpi-plan.yaml
    curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/rpi-implement.yaml -o ./nixos/modules/home-manager/goose/recipes/rpi-implement.yaml && echo -e "settings:\n  # goose_provider: \"@largeModelProvider\"\n  # goose_model: \"@largeModel@\"\n  goose_provider: \"@mainModelProvider@\"\n  goose_model: \"@mainModel@\"\n" >> ./nixos/modules/home-manager/goose/recipes/rpi-implement.yaml
    # curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/rpi-iterate.yaml -o ./nixos/modules/home-manager/goose/recipes/rpi-iterate.yaml
    
     curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/subrecipes/rpi-codebase-locator.yaml -o ./nixos/modules/home-manager/goose/recipes/subrecipes/rpi-codebase-locator.yaml
     curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/subrecipes/rpi-codebase-analyzer.yaml -o ./nixos/modules/home-manager/goose/recipes/subrecipes/rpi-codebase-analyzer.yaml
     curl -sL https://raw.githubusercontent.com/block/goose/main/documentation/src/pages/recipes/data/recipes/subrecipes/rpi-pattern-finder.yaml -o ./nixos/modules/home-manager/goose/recipes/subrecipes/rpi-pattern-finder.yaml
    */
  };
}
