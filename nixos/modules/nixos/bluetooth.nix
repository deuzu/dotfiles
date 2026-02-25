{ lib, config, ... }:
let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = with lib; {
    enable = mkEnableOption "Bluetooth";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };
}
