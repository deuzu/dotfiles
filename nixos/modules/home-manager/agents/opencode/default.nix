{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.modules.agents.opencode;
  env = config.modules.env.vars;
  gitEnable = config.modules.vcs.git.enable;
in
{
  options.modules.agents.opencode = with lib; {
    enable = mkEnableOption "opencode";
    preScripts = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      description = "Shell pre-scripts per folder";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      tui = {
        keybinds = { };
        scroll_acceleration = {
          enabled = false;
        };
      };
      settings = {
        autoupdate = false;
        share = "disabled";
        model = env.OPENCODE_MODEL;
        # small_model = "";
        provider = import ./provider.nix;
        agent = {
          plan = {
            model = env.OPENCODE_PLAN_MODEL;
          };
        };
        permission = import ./permission.nix;
        # plugins = [
        #   "@mohak34/opencode-notifier@latest"
        # ];
        server = {
          mdns = true;
        };
      };
    };

    # https://github.com/matanshavit/qrspi
    home.file = (myLib.folder pkgs ./agents ".config/opencode/agents" {
      defaultModel = env.OPENCODE_MODEL;
      largeModel = env.OPENCODE_PLAN_MODEL;
    });

    home.packages = [
      (import ./sandboxed-opencode.nix { inherit cfg pkgs lib myLib; })
    ];

    programs.git = lib.mkIf gitEnable {
      ignores = [
        "opencode.json"
        "opencode.jsonc"
      ];
    };
  };
}
