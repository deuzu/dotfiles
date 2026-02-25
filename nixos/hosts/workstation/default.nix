{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos
      ./sops.nix
      ./secrets.nix
    ];

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  virtualisation.docker.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.11";
}
