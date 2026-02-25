{ config, lib, pkgs, ... }:
let
  cfg = config.modules.gpg;
in
{
  options.modules.gpg = with lib; {
    enable = mkEnableOption "GPG";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      # enableSshSupport = true;
      pinentry.package = pkgs.pinentry-tty;
    };
  };
}
