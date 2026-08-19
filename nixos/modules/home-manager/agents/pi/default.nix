{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.modules.agents.pi;
  gitEnable = config.modules.vcs.git.enable;
  defaultProvider = cfg.defaultProvider;
  defaultModel = cfg.defaultModel;
  # largeProvider = cfg.largeProvider;
  largeModel = cfg.largeModel;
in
{
  options.modules.agents.pi = with lib; {
    enable = mkEnableOption "pi";
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
    home.packages = [
      (import ./sandboxed-pi.nix { inherit cfg pkgs lib myLib; })
    ];

    home.file = {
      ".pi/agent/AGENTS.md".source = ../AGENTS.md;
      ".pi/agent/models.json".text = builtins.toJSON (import ./models.nix { inherit cfg; });
      ".pi/agent/settings.json".text = builtins.toJSON (import ./settings.nix {
        inherit defaultProvider defaultModel;
      });
      ".pi/agent/subagents.json".text = builtins.toJSON (import ./subagents.nix { });
      ".pi/agent/extensions".source = import ./extensions.nix { inherit pkgs; };
    }
    // (myLib.folder pkgs ./agents ".pi/agent/agents" {
      inherit defaultModel largeModel;
    });

    home.sessionVariables = {
      PI_CACHE_RETENTION = "long";
      PI_SKIP_VERSION_CHECK = 1;
      PI_TELEMETRY = 0;
      PI_OFFLINE = 0;
    };

    programs.git = lib.mkIf gitEnable {
      ignores = [
        ".pi/"
        ".piignore"
      ];
    };
  };
}
