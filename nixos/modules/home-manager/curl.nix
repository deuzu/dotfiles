{ config, lib, pkgs, ... }:
let
  cfg = config.modules.curl;
in
{
  options.modules.curl = with lib; {
    enable = mkEnableOption "cURL";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      curl
    ];
  };
}
