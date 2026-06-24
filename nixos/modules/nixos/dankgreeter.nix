{ inputs, lib, config, ... }:

let
  cfg = config.modules.dankgreeter;
in
{
  imports = [
    inputs.dms.nixosModules.greeter
  ];

  options.modules.dankgreeter = with lib; {
    enable = mkEnableOption "DankGreeter";
    compositor = mkOption {
      type = types.str;
      description = "The name of the compositor to launch";
    };
    username = mkOption {
      type = types.str;
      description = "The user to use for DankGreeter configuration sync";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "${cfg.compositor}";
      configHome = "/home/${cfg.username}";
    };
  };
}
