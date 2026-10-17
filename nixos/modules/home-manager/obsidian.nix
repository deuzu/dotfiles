{ config, lib, pkgs, ... }:
let
  cfg = config.modules.obsidian;
in
{
  options.modules.obsidian = with lib; {
    enable = mkEnableOption "Obsidian";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];

    programs.git = lib.mkIf config.modules.vcs.git.enable {
      ignores = [
        ".obsidian/"
      ];
    };
  };
}
