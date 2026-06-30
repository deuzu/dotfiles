{ config, lib, ... }:
let
  cfg = config.modules.direnv;
  gitEnable = config.modules.vcs.git.enable;
in
{
  options.modules.direnv = with lib; {
    enable = mkEnableOption "Direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = config.modules.shell.bash.enable;
      enableNushellIntegration = lib.mkIf config.modules.shell.nushell.enable true;
      nix-direnv.enable = true;
    };

    programs.git = lib.mkIf gitEnable {
      ignores = [
        ".direnv"
      ];
    };
  };
}
