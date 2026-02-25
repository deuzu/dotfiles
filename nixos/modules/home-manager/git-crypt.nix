{ config, lib, pkgs, ... }:
let
  cfg = config.modules.gitCrypt;
in
{
  options.modules.gitCrypt = with lib; {
    enable = mkEnableOption "Git-Crypt";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git-crypt
    ];
  };
}
