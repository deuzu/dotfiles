{ lib, config, ... }:
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = with lib; {
    enable = mkEnableOption "SSH";

    allowUsers = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null; # Allows all users by default. Can be [ "user1" "user2" ]
      description = "Restrict SSH login to these users. null allows all users.";
    };

    maxAuthTries = mkOption {
      type = types.ints.positive;
      default = 3;
      description = "Maximum authentication attempts per connection before disconnecting.";
    };

    loginGraceTime = mkOption {
      type = types.str;
      default = "30";
      description = "Time allowed to complete authentication before disconnecting (sshd time format: seconds or 'm', 'h').";
    };

    kbdInteractiveAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow keyboard-interactive authentication (e.g. PAM/TOTP prompts).";
    };

    permitRootLogin = mkOption {
      type = types.enum [
        "yes"
        "prohibit-password"
        "without-password"
        "forced-commands-only"
        "no"
      ];
      default = "no";
      description = ''
        Whether and how root can log in over SSH.
        "prohibit-password" allows root login with SSH keys only.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 443 ];
      settings = {
        PermitRootLogin = cfg.permitRootLogin;
        PasswordAuthentication = false;
        AllowUsers = cfg.allowUsers;
        MaxAuthTries = cfg.maxAuthTries;
        LoginGraceTime = cfg.loginGraceTime;
        KbdInteractiveAuthentication = cfg.kbdInteractiveAuthentication;
        UseDns = true;
        X11Forwarding = false;
      };
    };
  };
}
