{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.modules.agents.pi;
  env = config.modules.env.vars;
  gitEnable = config.modules.vcs.git.enable;

  rawModel = if cfg.model != null then cfg.model else (env.OPENCODE_MODEL or "google/gemini-3.7-flash");
  modelParts = lib.splitString "/" rawModel;
  defaultProvider = if (builtins.length modelParts > 1) then builtins.head modelParts else "google";
  defaultModel = if (builtins.length modelParts > 1) then lib.concatStringsSep "/" (builtins.tail modelParts) else rawModel;
in
{
  options.modules.agents.pi = with lib; {
    enable = mkEnableOption "pi";
    binaryName = mkOption {
      type = types.str;
      default = "aip";
      description = "Name of the sandboxed binary created by Bubblewrap (e.g. aip)";
    };
    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default model for Pi";
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
      ".pi/agent/models.json".text = builtins.toJSON (import ./models.nix);
      ".pi/agent/settings.json".text = builtins.toJSON (import ./settings.nix {
        inherit defaultProvider defaultModel;
      });
      ".pi/agent/extensions".source = ./extensions;
      ".pi/agent/prompts".source = ./prompts;
    }
    // (myLib.folder pkgs ./agents ".pi/agent/agents" {
      defaultModel = rawModel;
      largeModel = env.OPENCODE_PLAN_MODEL or rawModel;
    });

    programs.git = lib.mkIf gitEnable {
      ignores = [
        ".pi/"
        ".piignore"
      ];
    };
  };
}
