{ lib, config, ... }:
let
  cfg = config.modules.eternalTerminal;
in
{
  options.modules.eternalTerminal = with lib; {
    enable = mkEnableOption "Eternal Terminal";
  };

  config = lib.mkIf cfg.enable {
    services.eternal-terminal = {
      enable = true;
    };
    networking.firewall.allowedTCPPorts = [ config.services.eternal-terminal.port ];
  };
}
