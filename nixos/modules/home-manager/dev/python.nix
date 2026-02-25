{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev.python;
in
{
  options.modules.dev.python = with lib; {
    enable = mkEnableOption "Python";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # python3Full
      uv
    ];
  };
}
