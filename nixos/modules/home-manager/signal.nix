{ config, lib, pkgs, ... }:
let
  cfg = config.modules.signal;

  signal-desktop-wrapped = pkgs.symlinkJoin {
    name = "signal-desktop";
    paths = [ pkgs.signal-desktop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/signal-desktop \
        --add-flags "--password-store=gnome-libsecret"
    '';
  };
in
{
  options.modules.signal = with lib; {
    enable = mkEnableOption "signal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      signal-desktop-wrapped
    ];
  };
}
