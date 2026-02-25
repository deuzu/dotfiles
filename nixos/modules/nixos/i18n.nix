{
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "altgt-intl";
  };

  console = {
    useXkbConfig = true;
  };
}
