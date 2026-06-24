{ pkgs, ... }: {
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos
      ./sops.nix
      ./config.nix
    ];

  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
  services.envfs.enable = true;
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  virtualisation.docker.enable = true;
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  environment.systemPackages = with pkgs; [
    nix-prefetch-scripts
  ];

}
