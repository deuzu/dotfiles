{ lib }:

{
  baseEnv = [
    "HOME"
    "PATH"
    "XDG_CONFIG_HOME"
    "XDG_CACHE_HOME"
    "XDG_DATA_HOME"
    "XDG_STATE_HOME"
    "USER"
    "TERM"
    "LANG"
    "LC_ALL"
    "LC_TIME"
    "LOCALE_ARCHIVE"
    "EDITOR"
    "NIX_REMOTE=daemon"
  ];

  baseRox = [
    "/usr"
    "/nix/store"
    "/run/current-system/sw/bin"
  ];

  baseRo = [
    "/etc"
    "/nix/var/nix/db"
    "/nix/var/nix/profiles"
    "/run/current-system/sw/etc"
    "/run/current-system/sw/lib/locale/locale-archive"
  ];

  baseRw = [
    "/nix/var/nix/daemon-socket"
    "$PWD"
  ];

  baseRwx = [
  ];

  baseTmp = [
    "/tmp"
  ];

  mkGitWorktreePreScript = { argArrayName, bindFlag, isBwrap ? false }: ''
    ${argArrayName}=()
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
          ${argArrayName}+=("${bindFlag}" "$MAIN_REPO_GIT_DIR" ${lib.optionalString isBwrap "\"$MAIN_REPO_GIT_DIR\""})
          # Bind all sibling worktrees
          while IFS= read -r wt; do
            [ "$wt" = "$PWD" ] && continue  # $PWD is already bound rw via baseRw
            ${argArrayName}+=("${bindFlag}" "$wt" ${lib.optionalString isBwrap "\"$wt\""})
          done < <(git --git-dir="$MAIN_REPO_GIT_DIR" worktree list --porcelain 2>/dev/null | awk '/^worktree /{sub(/^worktree /, ""); print}')
        fi
      fi
    fi
  '';
}
