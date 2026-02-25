{ config, lib, ... }:
let
  cfg = config.modules.terminals.ghostty;
in
{
  options.modules.terminals.ghostty = with lib; {
    enable = mkEnableOption "Ghostty Terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
    };
  };
}
