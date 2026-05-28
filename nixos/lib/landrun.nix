{ lib }:

{
  mkLandrun =
    pkgs:
    { name
    , executable
    , preScripts ? ""
    , extraRo ? [ ]
    , extraRw ? [ ]
    , extraRox ? [ ]
    , extraRwx ? [ ]
    , extraEnv ? [ ]
    , bestEffort ? false
    , unrestrictedNetwork ? true
    }:
    let
      baseRo = [ "/dev,/etc,/sys,/proc" ];
      baseRox = [ "/nix/store,/usr" ];
      baseRw = [
        "/dev/null,/dev/stdin,/dev/stdout,/dev/stderr,/dev/tty"
        "$HOME/go"
      ];
      baseRwx = [ ];
      baseEnv = [
        "HOME"
        "PATH"
        "XDG_CONFIG_HOME"
        "XDG_CACHE_HOME"
        "XDG_STATE_HOME"
        "USER"
        "TERM"
        "LANG"
        "LC_ALL"
      ];

      allRo = baseRo ++ extraRo;
      allRw = baseRw ++ extraRw;
      allRox = baseRox ++ extraRox;
      allRwx = baseRwx ++ extraRwx;
      allEnv = baseEnv ++ extraEnv;

      args = [ ]
        ++ lib.optional bestEffort "--best-effort"
        ++ lib.optional unrestrictedNetwork "--unrestricted-network"
        ++ map (p: "--ro ${p}") allRo
        ++ map (p: "--rox ${p}") allRox
        ++ map (p: "--rw ${p}") allRw
        ++ map (p: "--rwx ${p}") allRwx
        ++ map (e: "--env ${e}") allEnv;

      argsStr = lib.concatStringsSep " \\\n    " args;
    in
    pkgs.writeShellScriptBin name ''
      ${preScripts}

      exec ${pkgs.landrun}/bin/landrun \
        ${argsStr} \
        ${executable} "$@"
    '';
}
