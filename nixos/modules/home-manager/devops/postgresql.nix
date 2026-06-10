{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops.postgres;
in
{
  options.modules.devops.postgres = with lib; {
    enable = mkEnableOption "PostgreSQL";
    pgpassFiles = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Attribute set of pgpass files to be exported as environment variables.";
    };
    defaultPgpass = mkOption {
      type = types.str;
      description = "The name of the default pgpass file to use for PGPASSFILE.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      postgresql
    ];

    home.sessionVariables =
      let
        allFiles = lib.mapAttrs'
          (name: path: lib.nameValuePair "PGPASSFILE_${builtins.replaceStrings [ "-" ] [ "_" ] (lib.toUpper name)}" (toString path))
          cfg.pgpassFiles;

        defaultFile = lib.optionalAttrs (cfg.pgpassFiles ? "${cfg.defaultPgpass}") {
          PGPASSFILE = toString cfg.pgpassFiles."${cfg.defaultPgpass}";
        };
      in
      allFiles // defaultFile;
  };
}
