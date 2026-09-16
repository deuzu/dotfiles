{ lib, config, ... }:
let
  cfg = config.modules.crowdsec;
in
{
  options.modules.crowdsec = with lib; {
    enable = mkEnableOption "CrowdSec Security Engine with the firewall bouncer";

    sshdProtection = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Watch sshd logs (via journald) for brute-force attempts and ban
        offending IPs. Installs the `crowdsecurity/sshd` hub collection.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.crowdsec = {
      enable = true;
      autoUpdateService = true;
      localConfig.acquisitions = lib.optionals cfg.sshdProtection [
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          labels = {
            type = "syslog";
          };
        }
      ];
      hub.collections = [ "crowdsecurity/linux" ]
        ++ lib.optionals cfg.sshdProtection [ "crowdsecurity/sshd" ];
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
    };
  };
}
