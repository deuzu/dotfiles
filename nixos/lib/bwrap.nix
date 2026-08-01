{ lib }:

{
  mkBwrap =
    pkgs:
    { name
    , executable
    , preScripts ? ""
    , extraRo ? [ ]
    , extraRw ? [ ]
    , extraRox ? [ ]
    , extraRwx ? [ ]
    , extraTmp ? [ ]
    , extraEnv ? [ ]
    , unrestrictedNetwork ? false
    }:
    let
      sandboxBase = import ./sandbox-base-profile.nix { inherit lib; };
      basePreScripts = sandboxBase.mkGitWorktreePreScript {
        argArrayName = "DYNAMIC_SANDBOX_ARGS";
        bindFlag = "--bind-try";
        isBwrap = true;
      };
      baseRox = sandboxBase.baseRox;
      baseRwx = sandboxBase.baseRwx;
      baseRo = sandboxBase.baseRo;
      baseRw = sandboxBase.baseRw;
      baseEnv = sandboxBase.baseEnv;
      baseTmp = sandboxBase.baseTmp;

      allRox = baseRox ++ baseRo ++ extraRo ++ extraRox;
      allRwx = baseRwx ++ baseRw ++ extraRw ++ extraRwx;
      allEnv = baseEnv ++ extraEnv;
      allTmp = baseTmp ++ extraTmp;

      mkArgsRox = paths: lib.concatMap (p: [ "--ro-bind-try ${p} ${p}" ]) paths;
      mkArgsRwx = paths: lib.concatMap (p: [ "--bind-try ${p} ${p}" ]) paths;
      mkArgsTmp = paths: lib.concatMap (p: [ "--tmpfs ${p}" ]) paths;

      mkEnvArg = e:
        if lib.hasInfix "=" e then
          let
            parts = lib.splitString "=" e;
            name = lib.head parts;
            value = lib.concatStringsSep "=" (lib.tail parts);
          in
          "--setenv ${name} \"${value}\""
        else
          "--setenv ${e} \"\$${e}\"";

      args = [
        "--unshare-pid"
        "--unshare-uts"
        "--unshare-ipc"
        "--clearenv"
        "--die-with-parent"
        "--chdir $PWD"
        "--proc /proc"
        "--dev /dev"
      ]
      ++ lib.optional unrestrictedNetwork "--share-net"
      ++ mkArgsRox allRox
      ++ mkArgsRwx allRwx
      ++ mkArgsTmp allTmp
      ++ map mkEnvArg allEnv;

      argsStr = lib.concatStringsSep " \\\n    " args;
    in
    pkgs.writeShellScriptBin name ''
      ${basePreScripts}
      ${preScripts}

      exec ${pkgs.bubblewrap}/bin/bwrap \
        ${argsStr} \
        "''${DYNAMIC_SANDBOX_ARGS[@]}" \
        ${executable} "$@"
    '';
}
