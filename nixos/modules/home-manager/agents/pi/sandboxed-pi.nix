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
    export PATH="${pkgs.pi-coding-agent}/bin:$PATH"
  '' + generatedPreScripts;
  extraRo = cfg.sandboxExtraRo;
  extraRox = cfg.sandboxExtraRox;
  extraRw = cfg.sandboxExtraRw;
  extraRwx = cfg.sandboxExtraRwx;
  extraTmp = cfg.sandboxExtraTmp;
  extraEnv = cfg.sandboxExtraEnv;
  unrestrictedNetwork = true;
}
