{ config, lib, pkgs, ... }:
let
  cfg = config.modules.browser.librewolf;
in
{
  options.modules.browser.librewolf = with lib; {
    enable = mkEnableOption "Librewolf Internet Browser";
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      settings = {
        "beacon.enabled" = false;
        "browser.startup.page" = 3;
        "device.sensors.enabled" = false;
        "dom.battery.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "geo.enabled" = false;
        "media.peerconnection.enabled" = false;
        "privacy.clearHistory.cookiesAndStorage" = false;
        "privacy.clearHistory.siteSettings" = false;
        "privacy.firstparty.isolate" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "webgl.disabled" = true;
      };
    };
  };
}
