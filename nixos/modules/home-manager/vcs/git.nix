{ config, lib, ... }:
let
  cfg = config.modules.vcs.git;
in
{
  options.modules.vcs.git = with lib; {
    enable = mkEnableOption "Git";
    userName = mkOption {
      type = types.str;
    };
    userEmail = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.difftastic = {
      enable = true;
      git.enable = true;
      git.diffToolMode = true;
    };

    programs.git = {
      enable = true;
      signing = {
        key = null;
        signByDefault = true;
        format = "openpgp";
      };

      # ignores = [
      # ];

      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        alias = {
          f = "fetch";
          st = "status -sb";
          br = "branch";
          ci = "commit";
          cm = "commit -m";
          ame = "commit --amend";
          amn = "commit --amend --no-edit";
          co = "checkout";
          cp = "cherry-pick";
          rb = "rebase";
          rbc = "rebase --continue";
          rba = "rebase --abort";
          pu = "pull";
          pur = "pull --rebase";
          pop = "stash pop";
          lp = "log -p -M90%";
          lg = "log --pretty=oneline --abbrev-commit --graph --decorate";
          undo = "!git reset --soft HEAD^";
          p = "push";
          pf = "push --force-with-lease";
          ignore = "update-index --assume-unchanged";
          unignore = "update-index --no-assume-unchanged";
          ignored = "!git ls-files -v | grep \"^[[:lower:]]\"";
          squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} \"$@\");};f";
        };
        core = {
          autocrlf = "input";
          fileMode = false;
        };
        init.defaultBranch = "main";
        push.default = "current";
        "remote \"origin\"" = {
          prune = true;
        };
        gpg.program = "gpg";
        color.ui = true;
        log.date = "relative";
        format.pretty = "format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s";
      };
    };
  };
}
