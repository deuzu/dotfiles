{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.kubectl;
in
{
  options.modules.devops.kubectl = with lib; {
    enable = mkEnableOption "Kubectl Kubernetes CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
    ];
  };
}
