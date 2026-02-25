{ lib, config, ... }:
let
  cfg = config.modules.mosh;
in
{
  options.modules.mosh = with lib; {
    enable = mkEnableOption "Mosh Mobile Shell";
  };

  config = lib.mkIf cfg.enable {
    programs.mosh = {
      enable = true;
      openFirewall = true;
    };
  };
}
