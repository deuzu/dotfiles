{ lib, config, ... }:
let
  cfg = config.modules.fail2ban;
in
{
  options.modules.fail2ban = with lib; {
    enable = mkEnableOption "fail2ban intrusion prevention";

    bantime = mkOption {
      type = types.str;
      default = "1h";
      description = ''
        Default duration an offending IP is banned for (fail2ban time
        format: seconds or 'm', 'h', 'd' suffixes).
      '';
    };

    findtime = mkOption {
      type = types.str;
      default = "10m";
      description = ''
        Time window in which maxretry failures must occur for a ban to
        trigger.
      '';
    };

    maxretry = mkOption {
      type = types.ints.positive;
      default = 3;
      description = "Number of failures before an IP is banned.";
    };

    ignoreIP = mkOption {
      type = types.listOf types.str;
      default = [
        "127.0.0.1/8"
        "::1"
      ];
      description = "IPs, CIDR ranges or DNS names never to ban.";
    };

    sshdProtection = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the sshd jail, banning IPs that brute-force SSH logins.
        NixOS enables this jail by default when openssh is enabled and
        derives its ports from the configured openssh ports; this option
        allows disabling it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      inherit (cfg) bantime maxretry ignoreIP;

      jails = lib.optionalAttrs config.services.openssh.enable {
        sshd.settings = {
          enabled = cfg.sshdProtection;
          findtime = cfg.findtime;
        };
      };
    };
  };
}
