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
  name = cfg.binaryName;
  executable = "${pkgs.pi-coding-agent}/bin/pi";
  preScripts = ''
    mkdir -p "$HOME/.pi/agent"
    ${generatedPreScripts}
  '';
  extraRo = cfg.sandboxExtraRo ++ [
    "$HOME/.agents"
  ];
  extraRox = cfg.sandboxExtraRox;
  extraRw = cfg.sandboxExtraRw;
  extraRwx = cfg.sandboxExtraRwx;
  extraTmp = cfg.sandboxExtraTmp;
  extraEnv = cfg.sandboxExtraEnv;
  unrestrictedNetwork = true;
}
