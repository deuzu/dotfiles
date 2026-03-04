{ config, lib, ... }:
let
  cfg = config.modules.yazi;
in
{
  options.modules.yazi = with lib; {
    enable = mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      settings = {
        mgr.show_hidden = true;
      };
    };
  };
}
