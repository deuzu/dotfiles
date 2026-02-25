{ lib, config, ... }:
let
  cfg = config.modules.sound;
in
{
  options.modules.sound = with lib; {
    enable = mkEnableOption "Sound";
  };

  config = lib.mkIf cfg.enable {
    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
