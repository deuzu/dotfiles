{ config, lib, pkgs, ... }:
let
  cfg = config.modules.textEditors.vscode;
  gitEnable = config.modules.vcs.git.enable;
in
{
  options.modules.textEditors.vscode = with lib; {
    enable = mkEnableOption "VSCode Text Editor";
  };

  config = lib.mkIf cfg.enable {
    programs.vscodium = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        hashicorp.terraform
      ];
    };

    programs.git = lib.mkIf gitEnable {
      ignores = [
        ".vscode/"
      ];
    };
  };
}
