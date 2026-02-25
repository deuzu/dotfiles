{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.packer;
in
{
  options.modules.devops.packer = with lib; {
    enable = mkEnableOption "Packer Hashicorp";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      packer
    ];
  };
}
