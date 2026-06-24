{ pkgs, config, lib, ... }:
{
  networking.hostName = builtins.head (builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users));
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 34567 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # services.tailscale.enable = true;
}
