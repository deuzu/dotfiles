{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.tenv;
in
{
  options.modules.devops.tenv = with lib; {
    enable = mkEnableOption "tenv Terraform Version Manager";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.TENV_AUTO_INSTALL = "1";

    home.packages = with pkgs; [
      tenv
    ];
  };
}
