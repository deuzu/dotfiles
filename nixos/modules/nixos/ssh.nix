{ lib, config, ... }:
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = with lib; {
    enable = mkEnableOption "SSH";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 443 ];
      settings = {
        PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        PasswordAuthentication = false;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
      };
    };
  };
}
