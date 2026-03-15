{ config, lib, pkgs, ... }:
let
  cfg = config.modules.agents.opencode;
  env = config.modules.env.vars;
  gitEnable = config.modules.vcs.git.enable;
in
{
  options.modules.agents.opencode = with lib; {
    enable = mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = {
        model = env.OPENCODE_MODEL;
        # small_model = "";
        provider = {
          google = {
            options = {
              apiKey = "{env:GOOGLEAI_API_KEY}";
            };
          };
          openai = {
            options = {
              apiKey = "{env:OPENAI_API_KEY}";
            };
          };
        };
        agent = {
          plan = {
            model = env.OPENCODE_PLAN_MODEL;
          };
        };
        keybinds = { };
        permission = {
          bash = {
            "*" = "allow";
            "env*" = "deny";
            "ssh*" = "deny";
            "sops*" = "deny";
            "git-crypt*" = "deny";
            "psql*" = "ask";
            "curl*" = "ask";
            "http*" = "ask";
            "nix-rebuild*" = "ask";
            "git push*" = "ask";
            "git commit*" = "ask";
            "docker push*" = "ask";
            "terraform*" = "ask";
            "packer*" = "ask";
            "kubectl*" = "ask";
          };
        };
        tui = {
          scroll_acceleration = {
            enabled = false;
          };
        };
        server = {
          mdns = true;
        };
        share = "disabled";
      };
    };

    home.file = builtins.listToAttrs (map
      (file: {
        name = ".config/opencode/agents/${file}";
        value.text = builtins.readFile (pkgs.replaceVars ./agents/${file} {
          defaultModel = env.OPENCODE_MODEL;
          largeModel = env.OPENCODE_PLAN_MODEL;
        });
      })
      (builtins.attrNames (lib.filterAttrs (name: type: type == "regular") (builtins.readDir ./agents))))
    ;

    home.packages = [
      (pkgs.writeShellScriptBin "ai" ''
        mkdir -p "$HOME/.config/opencode"

        exec ${pkgs.landrun}/bin/landrun \
          --best-effort \
          --ro /dev,/etc,/sys,/proc \
          --rox /nix/store,/usr \
          --rw /dev/null,/dev/stdin,/dev/stdout,/dev/stderr,/dev/tty \
          --rw "$HOME/.config/opencode" \
          --rw "$HOME/.local/share/opencode" \
          --rw "$HOME/.local/state/opencode" \
          --rw "$HOME/.cache/opencode" \
          --ro "$HOME/.agents" \
          --rw "$HOME/.cache/helix" \
          --rw "$HOME/.config/gcloud" \
          --ro "$HOME/.config/gh" \
          --rw "$HOME/go" \
          --rw "$HOME/.npm" \
          --rwx "$HOME/.tenv" \
          --ro "$HOME/.terraform.d" \
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
          --env EDITOR \
          --env OPENAI_API_KEY \
          --env GOOGLEAI_API_KEY \
          --env OPENCODE_MODEL \
          --env OPENCODE_PLAN_MODEL \
          --env OPENCODE_ENABLE_EXA \
          opencode "$@"
      '')
    ];

    programs.git = lib.mkIf gitEnable {
      ignores = [
        "opencode.json"
        "opencode.jsonc"
      ];
    };
  };
}
