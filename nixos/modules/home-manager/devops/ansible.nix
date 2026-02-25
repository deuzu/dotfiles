{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.ansible;
in
{
  options.modules.devops.ansible = with lib; {
    enable = mkEnableOption "Ansible";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ansible
    ];
  };
}
