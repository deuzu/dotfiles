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
    , extraTmp ? [ ]
    , unrestrictedNetwork ? true
    }:
    let
      sandboxBase = import ./sandbox-base-profile.nix { inherit lib; };
      basePreScripts = sandboxBase.mkGitWorktreePreScript {
        argArrayName = "DYNAMIC_SANDBOX_ARGS";
        bindFlag = "--rwx";
      };
      baseRo = sandboxBase.baseRo ++ [ "/dev" "/sys" "/proc" ];
      baseRox = sandboxBase.baseRox;
      baseRw = sandboxBase.baseRw ++ [
        "/dev/null"
        "/dev/stdin"
        "/dev/stdout"
        "/dev/stderr"
        "/dev/tty"
      ];
      baseRwx = sandboxBase.baseRwx;
      baseEnv = sandboxBase.baseEnv;

      allRo = baseRo ++ extraRo;
      allRw = baseRw ++ extraRw;
      allRox = baseRox ++ extraRox;
      allRwx = baseRwx ++ extraRwx;
      allEnv = baseEnv ++ extraEnv;

      args = [
        "--best-effort"
      ]
      ++ lib.optional unrestrictedNetwork "--unrestricted-network"
      ++ map (p: "--ro ${p}") allRo
      ++ map (p: "--rox ${p}") allRox
      ++ map (p: "--rw ${p}") allRw
      ++ map (p: "--rwx ${p}") allRwx
      ++ map (e: "--env ${e}") allEnv;

      argsStr = lib.concatStringsSep " \\\n    " args;
    in
    pkgs.writeShellScriptBin name ''
      ${basePreScripts}
      ${preScripts}

      exec ${pkgs.landrun}/bin/landrun \
        ${argsStr} \
        "''${DYNAMIC_SANDBOX_ARGS[@]}" \
        ${executable} "$@"
    '';
}
