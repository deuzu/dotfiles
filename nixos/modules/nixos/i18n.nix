{
  time.timeZone = "Europe/Paris";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "intl";
  };

  console = {
    useXkbConfig = true;
  };
}
