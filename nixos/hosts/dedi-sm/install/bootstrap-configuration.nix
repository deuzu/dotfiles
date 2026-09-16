{ pkgs, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  networking.hostName = "dedi-sm";
  networking.useDHCP = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
  ];

  environment.systemPackages = with pkgs; [
    hello
    curl
    git
    vim
  ];

  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
