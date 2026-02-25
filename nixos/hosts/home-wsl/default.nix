# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  imports = [
    ../../modules/nixos
    ./secrets.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "ftouya";
  virtualisation.docker.enable = true;

  programs.dconf.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.11";
}
