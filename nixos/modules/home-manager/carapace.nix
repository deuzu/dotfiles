{ config, lib, ... }:
let
  cfg = config.modules.carapace;
in
{
  options.modules.carapace = with lib; {
    enable = mkEnableOption "Carapace";
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
    };
  };
}
