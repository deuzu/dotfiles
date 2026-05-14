{ config, lib, pkgs, ... }:
let
  cfg = config.modules.agents.gooseCli;
  env = config.modules.env;
  gitEnable = config.modules.vcs.git.enable;

  deployFolder = srcDir: destDir: vars:
    builtins.listToAttrs (map
      (file: {
        name = "${destDir}/${file}";
        value.text = builtins.readFile (pkgs.replaceVars (srcDir + "/${file}") vars);
      })
      (builtins.attrNames (lib.filterAttrs (name: type: type == "regular") (builtins.readDir srcDir))));
in
{
  options.modules.agents.gooseCli = with lib; {
    enable = mkEnableOption "Goose CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      goose-cli

      (pkgs.writeShellScriptBin "aig" ''
        mkdir -p "$HOME/.config/goose"

        exec ${pkgs.landrun}/bin/landrun \
          --best-effort \
          --ro /dev,/etc,/sys,/proc \
          --rox /nix/store,/usr \
          --rw /dev/null,/dev/stdin,/dev/stdout,/dev/stderr,/dev/tty \
          --rw "$HOME/.config/goose" \
          --rw "$HOME/.local/share/goose" \
          --rw "$HOME/.local/state/goose" \
          --rw "$HOME/.cache/goose" \
          --rw "$HOME/go" \
          --rwx /tmp \
          --rwx "$PWD" \
          --unrestricted-network \
          --env HOME \
          --env PATH \
          --env XDG_CONFIG_HOME \
          --env XDG_CACHE_HOME \
          --env XDG_STATE_HOME \
          --env USER \
          --env TERM \
          --env LANG \
          --env LC_ALL \
          --env DBUS_SESSION_BUS_ADDRESS \
          --env GOOSE_PROVIDER \
          --env GOOSE_MODEL \
          --env GOOSE_PLANNER_PROVIDER \
          --env GOOSE_PLANNER_MODEL \
          --env GOOSE_EDITOR_API_KEY \
          --env GOOSE_EDITOR_HOST \
          --env GOOSE_EDITOR_MODEL \
          --env OPENAI_API_KEY \
          --env GOOGLEAI_API_KEY \
          --env MISTRAL_API_KEY \
          ${pkgs.goose-cli}/bin/goose "$@"
      '')
    ];

    home.file = {
      ".config/goose/config.yaml".text = builtins.readFile (pkgs.replaceVars ./config.yaml { });
    } // (deployFolder ./recipes ".config/goose/recipes" {
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
