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
  preScripts = generatedPreScripts;
  extraRo = cfg.sandboxExtraRo;
  extraRox = cfg.sandboxExtraRox;
  extraRw = cfg.sandboxExtraRw;
  extraRwx = cfg.sandboxExtraRwx;
  extraTmp = cfg.sandboxExtraTmp;
  extraEnv = cfg.sandboxExtraEnv;
  unrestrictedNetwork = true;
}
