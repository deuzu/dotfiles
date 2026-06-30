{ config, lib, pkgs, ... }:
let
  cfg = config.modules.starship;
  jjCfg = config.modules.vcs.jujutsu;
in
{
  options.modules.starship = with lib; {
    enable = mkEnableOption "Starship";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = config.modules.shell.bash.enable;
      enableNushellIntegration = lib.mkIf config.modules.shell.nushell.enable true;
      settings = {
        format = "$username$hostname$localip$shlvl$shell$nix_shell$all$kubernetes$line_break$jobs$character";

        hostname = {
          disabled = false;
          format = "[$ssh_symbol]($style)";
        };

        shell = {
          disabled = true;
          bash_indicator = " ";
          nu_indicator = "";
          format = "[$indicator]($style)";
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
        };

        # custom = {
        #   jj = lib.mkIf jjCfg.enable {
        #     symbol = "🥋 ";
        #     command = ''
        #       jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
        #         separate(" ",
        #           concat(
        #             if(conflict, "💥"),
        #             if(divergent, "🚧"),
        #             if(hidden, "👻"),
        #             if(immutable, "🔒"),
        #           ),
        #           change_id.shortest(4),
        #           bookmarks
        #         )
        #       '
        #     '';
        #     when = "jj --ignore-working-copy root";
        #     shell = [ "sh" "--norc" "--noprofile" ];
        #   };
        # };

        nix_shell.format = "[$symbol]($style)";
        aws.format = "[$symbol$profile]($style)";

        gcloud = {
          format = "[$symbol$project]($style) ";
          symbol = "☁️ ";
        };


        kubernetes = {
          disabled = false;
          format = "[$symbol$context]($style) ";
        };

        aws.disabled = true;
        battery.disabled = true;
        status.disabled = true;
        username.disabled = true;
        cmd_duration.disabled = true;
        git_status.disabled = true;
        package.disabled = true;
        php.disabled = true;
        golang.disabled = true;
        rust.disabled = true;
        terraform.disabled = true;
        helm.disabled = true;
        nodejs.disabled = true;
        python.disabled = true;

      };
    };
  };
}
