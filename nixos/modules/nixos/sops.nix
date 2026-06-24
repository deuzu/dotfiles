{ config, lib, pkgs, ... }:
let
  cfg = config.modules.sops;
in
{
  options.modules.sops = with lib; {
    enable = mkEnableOption "Secret OPerationS";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
    ];
  };
}
