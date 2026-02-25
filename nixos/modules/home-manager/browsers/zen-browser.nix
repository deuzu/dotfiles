{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.modules.browser.zen;
in
{
  options.modules.browser.zen = with lib; {
    enable = mkEnableOption "Zen Internet Browser";
  };

  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
      };
    };
  };
}
