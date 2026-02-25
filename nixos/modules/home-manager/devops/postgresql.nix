{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops.postgres;
in
{
  options.modules.devops.postgres = with lib; {
    enable = mkEnableOption "PostgreSQL";
    pgpass = mkOption {
      type = types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      postgresql
    ];

    home.sessionVariables = lib.mkIf (cfg.pgpass != null) {
      PGPASSFILE = cfg.pgpass;
    };
  };
}
