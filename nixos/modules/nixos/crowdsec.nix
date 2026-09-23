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
      # The firewall bouncer authenticates against the Local API (LAPI).
      # Upstream defaults this to false, and enabling it requires explicit
      # credential file paths (upstream default is null, which breaks eval).
      settings = {
        general.api.server.enable = true;
        lapi.credentialsFile = "/var/lib/crowdsec/state/lapi-credentials.yaml";
        capi.credentialsFile = "/var/lib/crowdsec/state/online_api_credentials.yaml";
      };
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

      # The auto-registration service is broken upstream (nixpkgs#526506):
      # it invokes the raw `cscli` binary without `-c`, which falls back to
      # /etc/crowdsec/config.yaml (nonexistent on NixOS), and its
      # StateDirectory hijacks /var/lib/crowdsec via DynamicUser.
      # We register the bouncer manually instead and point the bouncer at the
      # key file below.
      registerBouncer.enable = false;
      secrets.apiKeyPath = "/var/lib/crowdsec-firewall-bouncer/api-key";
    };
  };
}
