{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.diffle;
in
{
  options.modules.diffle = with lib; {
    enable = mkEnableOption "diffle (local git diff reviewer in the browser)";

    package = mkOption {
      type = types.package;
      default = inputs.diffle.packages.${pkgs.system}.default;
      description = "diffle package to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
