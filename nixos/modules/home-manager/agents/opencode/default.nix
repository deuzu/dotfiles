{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.modules.agents.opencode;
  gitEnable = config.modules.vcs.git.enable;
  defaultModel = "${cfg.defaultProvider}/${cfg.defaultModel}";
  largeModel = "${cfg.largeProvider}/${cfg.largeModel}";
in
{
  options.modules.agents.opencode = with lib; {
    enable = mkEnableOption "opencode";
    binaryName = mkOption {
      type = types.str;
      default = "ai";
      description = "Name of the sandboxed binary created by the sandbox";
    };
    defaultProvider = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default provider for Pi";
    };
    defaultModel = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default model for Pi";
    };
    largeProvider = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Large provider for Pi";
    };
    largeModel = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Large model for Pi";
    };
    baseUrls = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Base URLs for LLM providers";
    };
    preScripts = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      description = "Shell pre-scripts per folder";
    };
    sandboxExtraRo = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Read only files or folders available inside the sandbox";
    };
    sandboxExtraRox = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Read only executable files or folders available inside the sandbox";
    };
    sandboxExtraRw = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Read write files or folders available inside the sandbox";
    };
    sandboxExtraRwx = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Read write executable files or folders available inside the sandbox";
    };
    sandboxExtraTmp = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Tmpfs temporary files or folders available inside the sandbox";
    };
    sandboxExtraEnv = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Env vars available inside the sandbox";
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
        model = defaultModel;
        # small_model = "";
        provider = import ./provider.nix { inherit cfg; };
        agent = {
          plan = {
            model = largeModel;
          };
        };
        permission = import ./permission.nix;
        plugin = [
        # "@simonwjackson/opencode-direnv"
        # "@mohak34/opencode-notifier@latest"
        ];
        server = {
          mdns = true;
        };
      };
    };

    # https://github.com/matanshavit/qrspi
    home.file = (myLib.folder pkgs ./agents ".config/opencode/agents" {
      inherit defaultModel largeModel;
    });

    home.packages = [
      (import ./sandboxed-opencode.nix { inherit cfg pkgs lib myLib; })
    ];

    home.sessionVariables = {
        OPENCODE_ENABLE_EXA = 1;
        OPENCODE_DISABLE_CLAUDE_CODE = 1;
        OPENCODE_MODEL = defaultModel;
        OPENCODE_PLAN_MODEL = largeModel;
    };

    programs.git = lib.mkIf gitEnable {
      ignores = [
        "opencode.json"
        "opencode.jsonc"
      ];
    };
  };
}
