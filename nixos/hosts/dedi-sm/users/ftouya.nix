{
  programs.home-manager.enable = true;

  home = {
    username = "ftouya";
    homeDirectory = "/home/ftouya";
    stateVersion = "24.11";
  };

  imports = [
    ../../../modules/home-manager
    # ./ftouya.sops.nix
    ./ftouya.config.nix
  ];
}
