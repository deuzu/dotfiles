{
  showBattery = true;
  showWeather = false;
  weatherEnabled = false;
  showClipboard = true;
  controlCenterShowVpnIcon = true;

  acMonitorTimeout = 300;
  acLockTimeout = 360;
  acSuspendTimeout = 0;
  acSuspendBehavior = 2;
  acProfileName = "";
  batteryMonitorTimeout = 300;
  batteryLockTimeout = 360;
  batterySuspendTimeout = 0;
  batterySuspendBehavior = 0;
  batteryProfileName = "";
  batteryChargeLimit = 100;
  lockBeforeSuspend = true;
  loginctlLockIntegration = true;
  fadeToLockEnabled = true;
  fadeToLockGracePeriod = 5;
  fadeToDpmsEnabled = true;
  fadeToDpmsGracePeriod = 5;

  lockScreenShowPowerActions = true;
  lockScreenShowSystemIcons = false;
  lockScreenShowTime = true;
  lockScreenShowDate = true;
  lockScreenShowProfileImage = false;
  lockScreenShowPasswordField = false;
  lockScreenShowMediaPlayer = false;
  lockScreenPowerOffMonitorsOnLock = false;

  controlCenterWidgets = [
    {
      id = "volumeSlider";
      enabled = true;
      width = 50;
    }
    {
      id = "brightnessSlider";
      enabled = true;
      width = 50;
    }
    {
      id = "wifi";
      enabled = true;
      width = 50;
    }
    {
      id = "bluetooth";
      enabled = true;
      width = 50;
    }
    {
      id = "builtin_vpn";
      enabled = true;
      width = 100;
    }
    {
      id = "audioOutput";
      enabled = true;
      width = 50;
    }
    {
      id = "audioInput";
      enabled = true;
      width = 50;
    }
    {
      id = "nightMode";
      enabled = true;
      width = 50;
    }
    {
      id = "darkMode";
      enabled = true;
      width = 50;
    }
  ];

  "barConfigs" = [
    {
      id = "default";
      name = "Main Bar";
      enabled = true;
      position = 0;
      screenPreferences = [
        "all"
      ];
      showOnLastDisplay = true;
      leftWidgets = [
        "workspaceSwitcher"
        "systemTray"
      ];
      centerWidgets = [
        "music"
        "clock"
      ];
      rightWidgets = [
        "dockerManager"
        "dankDiskUsage"
        "cpuUsage"
        "battery"
        "controlCenterButton"
      ];
      spacing = 4;
      innerPadding = 4;
      bottomGap = 0;
      transparency = 1;
      widgetTransparency = 1;
      squareCorners = false;
      noBackground = false;
      gothCornersEnabled = false;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 12;
      borderEnabled = false;
      borderColor = "surfaceText";
      borderOpacity = 1;
      borderThickness = 1;
      fontScale = 1;
      autoHide = false;
      autoHideDelay = 250;
      openOnOverview = false;
      visible = true;
      popupGapsAuto = true;
      popupGapsManual = 4;
    }
  ];
}
