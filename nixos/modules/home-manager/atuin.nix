{ config, lib, ... }:
let
  cfg = config.modules.atuin;
in
{
  options.modules.atuin = with lib; {
    enable = mkEnableOption "Atuin";
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
    };
  };
}
