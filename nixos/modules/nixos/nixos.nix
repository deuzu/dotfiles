{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  environment.systemPackages = with pkgs; [
    nix-prefetch-scripts
  ];
}
