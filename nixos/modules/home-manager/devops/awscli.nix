{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.awscli;
in
{
  options.modules.devops.awscli = with lib; {
    enable = mkEnableOption "awscli";
    accessKeyId = mkOption {
      type = types.path;
    };
    accessKeySecret = mkOption {
      type = types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
    ];
  };
}
