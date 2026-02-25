{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.krr;
in
{
  options.modules.devops.krr = with lib; {
    enable = mkEnableOption "krr Kubernetes Resource Recommendations";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      krr
    ];
  };
}
