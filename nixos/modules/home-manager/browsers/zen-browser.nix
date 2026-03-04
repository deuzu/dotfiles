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

  # https://github.com/luisnquin/nixos-config/tree/main/home/modules/programs/browser/zen
  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      suppressXdgMigrationWarning = true;
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
      # search = {
      #   force = true;
      #   default = "todo";
      #   engines =
      #     let
      #       nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      #     in
      #     {
      #       "Nix Packages" = {
      #         urls = [
      #           {
      #             template = "https://search.nixos.org/packages";
      #             params = [
      #               {
      #                 name = "type";
      #                 value = "packages";
      #               }
      #               {
      #                 name = "channel";
      #                 value = "unstable";
      #               }
      #               {
      #                 name = "query";
      #                 value = "{searchTerms}";
      #               }
      #             ];
      #           }
      #         ];
      #         icon = nixSnowflakeIcon;
      #         definedAliases = [ "np" ];
      #       };
      #       "Nix Options" = {
      #         urls = [
      #           {
      #             template = "https://search.nixos.org/options";
      #             params = [
      #               {
      #                 name = "channel";
      #                 value = "unstable";
      #               }
      #               {
      #                 name = "query";
      #                 value = "{searchTerms}";
      #               }
      #             ];
      #           }
      #         ];
      #         icon = nixSnowflakeIcon;
      #         definedAliases = [ "nop" ];
      #       };
      #       "Home Manager Options" = {
      #         urls = [
      #           {
      #             template = "https://home-manager-options.extranix.com/";
      #             params = [
      #               {
      #                 name = "query";
      #                 value = "{searchTerms}";
      #               }
      #               {
      #                 name = "release";
      #                 value = "master"; # unstable
      #               }
      #             ];
      #           }
      #         ];
      #         icon = nixSnowflakeIcon;
      #         definedAliases = [ "hmop" ];
      #       };
      #     };
      # };
      # profile.default = {
      #   isDefault = true;
      #   settings = {};
      # };
    };
  };
}
