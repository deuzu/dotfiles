{ config, lib, pkgs, ... }:
let
  cfg = config.modules.agents.opencode;
  env = config.modules.env.vars;
  gitEnable = config.modules.vcs.git.enable;
  folder = srcDir: destDir: vars:
    builtins.listToAttrs (map
      (file: {
        name = "${destDir}/${file}";
        value.text = builtins.readFile (pkgs.replaceVars (srcDir + "/${file}") vars);
      })
      (builtins.attrNames (lib.filterAttrs (name: type: type == "regular") (builtins.readDir srcDir))));
in
{
  options.modules.agents.opencode = with lib; {
    enable = mkEnableOption "opencode";
    preScripts = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      description = "A mapping of directory paths to shell scripts to execute before starting opencode. Useful for conditional environment setups based on $PWD.";
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
          mistral = {
            options = {
              apiKey = "{env:MISTRAL_API_KEY}";
            };
            models = {
              "mistral-medium-3-5" = {
                name = "Mistral Medium (3.5) High Reasoning";
                options = {
                  "reasoningEffort" = "high";
                };
              };
            };
          };
        };
        agent = {
          plan = {
            model = env.OPENCODE_PLAN_MODEL;
          };
        };
        permission = {
          bash = {
            "*" = "allow";
            "env*" = "deny";
            "ssh *" = "deny";
            "sops *" = "deny";
            "git-crypt *" = "deny";
            "gpg *" = "deny";
            "terraform *" = "deny";
            # "terraform fmt*" = "allow";
            # "terraform validate*" = "allow";
            "git add *" = "deny";
            "git commit *" = "deny";
            "git push *" = "deny";
            "curl" = "ask";
            # "kubectl*" = "allow";
            # "gcloud*" = "allow";
            # "jq*" = "allow";
            # "echo*" = "allow";
            # "cat*" = "allow";
            # "head*" = "allow";
            # "less*" = "allow";
            # "tail*" = "allow";
            # "ls*" = "allow";
            # "find*" = "allow";
            # "grep*" = "allow";
            # "rg*" = "allow";
          };
        };
        # plugins = [
        #   "@mohak34/opencode-notifier@latest"
        # ];
        server = {
          mdns = true;
        };
      };
    };

    # https://github.com/matanshavit/qrspi
    home.file = (folder ./agents ".config/opencode/agents" {
      defaultModel = env.OPENCODE_MODEL;
      largeModel = env.OPENCODE_PLAN_MODEL;
    });

    home.packages =
      let
        generatedPreScripts = lib.concatStringsSep "\n" (lib.mapAttrsToList
          (path: script: ''
            if [[ "$PWD" == "${path}"* ]]; then
              ${script}
            fi
          '')
          cfg.preScripts);
      in
      [
        (pkgs.writeShellScriptBin "ai" ''
          # if [[ "$PWD" != "$HOME/Projects/"* ]]; then
          #   echo "🚨 Security Error: Refusing to run opencode from $PWD."
          #   echo "For security reasons, this agent can only be executed from within $HOME/Projects/..."
          #   exit 1
          # fi

          mkdir -p "$HOME/.config/gcloud-aiagent"

          ${generatedPreScripts}

          export CLOUDSDK_CONFIG="$HOME/.config/gcloud-aiagent"
          if [ -n "$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE" ] && [ -f "$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE" ]; then
            export GOOGLE_APPLICATION_CREDENTIALS="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
            export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
            gcloud auth activate-service-account --key-file="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
          fi

          exec ${pkgs.landrun}/bin/landrun \
            --ro /dev,/etc,/sys,/proc \
            --rox /nix/store,/usr \
            --rw /dev/null,/dev/stdin,/dev/stdout,/dev/stderr,/dev/tty \
            --rw "$HOME/.config/opencode" \
            --rw "$HOME/.local/share/opencode" \
            --rw "$HOME/.local/state/opencode" \
            --rw "$HOME/.cache/opencode" \
            --ro "$HOME/.agents" \
            --rw "$HOME/.cache/helix" \
            --rw "$HOME/.config/gcloud-aiagent" \
            --ro "$HOME/.config/gh" \
            --ro "$HOME/.kube/" \
            --rw "$HOME/go" \
            --rw "$HOME/.cache/go" \
            --rw "$HOME/.cache/go-build" \
            --rw "$HOME/.cache/gopls" \
            --rw "$HOME/.cache/golangci-lint" \
            --rw "$HOME/.cache/goimports" \
            --rw "$HOME/.npm" \
            --rox "$HOME/.tenv" \
            --ro "$HOME/.terraform.d" \
            --rw /tmp \
            --rw "$PWD" \
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
            --env MISTRAL_API_KEY \
            --env OPENCODE_MODEL \
            --env OPENCODE_PLAN_MODEL \
            --env OPENCODE_ENABLE_EXA \
            --env CLOUDSDK_CONFIG \
            --env GOOGLE_APPLICATION_CREDENTIALS \
            --env CLOUDSDK_ACTIVE_CONFIG_NAME \
            --env CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE \
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
