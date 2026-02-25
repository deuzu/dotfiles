{ config, lib, pkgs, ... }:
let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = with lib; {
    enable = mkEnableOption "tailscale";
  };

  config = lib.mkIf cfg.enable {
    # services.tailscale.enable = true;
    # home.packages = with pkgs; [
    #   tailscale
    # ];
  };
}
