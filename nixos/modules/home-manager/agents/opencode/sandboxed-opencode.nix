{ cfg, pkgs, lib, myLib }:

let
  generatedPreScripts = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (path: script: ''
      if [[ "$PWD" == "${path}"* ]]; then
        ${script}
      fi
    '')
    cfg.preScripts);
in

myLib.mkBwrap pkgs {
  name = "ai";
  executable = "opencode";
  chdir = "$PWD";
  preScripts = ''
    ${generatedPreScripts}

    mkdir -p "$HOME/.config/gcloud-aiagent"
    export CLOUDSDK_CONFIG="$HOME/.config/gcloud-aiagent"
    if [ -n "$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE" ] && [ -f "$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE" ]; then

      export GOOGLE_APPLICATION_CREDENTIALS="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
      export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
      gcloud auth activate-service-account --key-file="$CLOUDSDK_SERVICE_ACCOUNT_KEY_FILE"
    fi
  '';
  extraRo = [
    "$HOME/.agents"
    "$HOME/.config/helix"
    "$HOME/.kube/"
  ];
  extraRox = [
  ];
  extraRw = [
    "$HOME/.config/opencode"
    "$HOME/.local/share/opencode"
    "$HOME/.local/state/opencode"
    "$HOME/.cache/opencode"
    "$HOME/.cache/helix"
    "$HOME/.config/gcloud-aiagent"
    "$HOME/.cache/go"
    "$HOME/.cache/go-build"
    "$HOME/.cache/gopls"
    "$HOME/.cache/golangci-lint"
    "$HOME/.cache/goimports"
    "$HOME/.npm"
    "$HOME/.terraform.d"
    "$PWD"
  ];
  extraRwx = [
    "$HOME/.tenv"
  ];
  extraTmp = [
    # "$HOME/.cache"
    # "$HOME/.config"
  ];
  extraEnv = [
    "OPENCODE_MODEL"
    "OPENCODE_PLAN_MODEL"
    "OPENCODE_ENABLE_EXA"
    "OPENAI_API_KEY"
    "GOOGLEAI_API_KEY"
    "MISTRAL_API_KEY"
    "CLOUDSDK_CONFIG"
    "GOOGLE_APPLICATION_CREDENTIALS"
    "CLOUDSDK_ACTIVE_CONFIG_NAME"
    "CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE"
  ];
  unrestrictedNetwork = true;
}
