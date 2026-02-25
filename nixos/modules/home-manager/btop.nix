{ config, lib, ... }:
let
  cfg = config.modules.btop;
in
{
  options.modules.btop = with lib; {
    enable = mkEnableOption "btop";
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
    };
  };
}
