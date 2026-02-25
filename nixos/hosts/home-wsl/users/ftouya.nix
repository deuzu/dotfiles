{
  imports = [
    ../../../modules/home-manager
    ./ftouya.secrets.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
