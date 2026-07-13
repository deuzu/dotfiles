{ lib }:

{
  mkBwrap =
    pkgs:
    { name
    , executable
    , chdir ? "~/"
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
      basePreScripts = ''
        DYNAMIC_BWRAP_ARGS=()
        # If git worktree detected, adds bind to the main repo 
        if [ -f "$PWD/.git" ]; then
          GIT_DIR_LINE=$(head -n 1 "$PWD/.git")
          if [[ "$GIT_DIR_LINE" == "gitdir: "* ]]; then
            GIT_DIR_PATH="''${GIT_DIR_LINE#gitdir: }"
            # Convert relative path to absolute path
            if [[ "$GIT_DIR_PATH" != /* ]]; then
              GIT_DIR_PATH="$PWD/$GIT_DIR_PATH"
            fi
            # from /path/to/repo/.git/worktree/wkrtr-name to /path/to/repo/.git
            MAIN_REPO_GIT_DIR=$(dirname "$(dirname "$GIT_DIR_PATH")")
            if [ -d "$MAIN_REPO_GIT_DIR" ]; then
              DYNAMIC_BWRAP_ARGS+=("--bind-try" "$MAIN_REPO_GIT_DIR" "$MAIN_REPO_GIT_DIR")
            fi
          fi
        fi
      '';
      baseRox = [
        "/usr"
        "/etc"
        "/nix/store"
        "/nix/var/nix/db"
        "/run/current-system/sw/bin"
        "/run/current-system/sw/etc"
        "/run/current-system/sw/lib/locale/locale-archive"
        "$HOME/.config/git/config"
      ];
      baseRwx = [
        "/nix/var/nix/daemon-socket"
      ];
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
        "LC_TIME"
        "LOCALE_ARCHIVE"
        "EDITOR"
      ];
      baseTmp = [ "/tmp" ];

      allRox = baseRox ++ extraRo ++ extraRox;
      allRwx = baseRwx ++ extraRw ++ extraRwx;
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
        "--chdir ${chdir}"
        "--proc /proc"
        "--dev /dev"
        "--setenv NIX_REMOTE daemon"
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
        "''${DYNAMIC_BWRAP_ARGS[@]}" \
        ${executable} "$@"
    '';
}
