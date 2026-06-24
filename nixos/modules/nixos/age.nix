{ config, lib, pkgs, ... }:
let
  cfg = config.modules.age;
in
{
  options.modules.age = with lib; {
    enable = mkEnableOption "Age file encryption";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      age
    ];
  };
}
