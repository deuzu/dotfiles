{ config, lib, ... }:
let
  cfg = config.modules.tealdeer;
in
{
  options.modules.tealdeer = with lib; {
    enable = mkEnableOption "TealDeer";
  };

  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
    };
  };
}
