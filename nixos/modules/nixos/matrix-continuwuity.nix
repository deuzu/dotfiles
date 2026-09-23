{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.matrix-continuwuity;
in
{
  options.modules.matrix-continuwuity = with lib; {
    enable = mkEnableOption "Continuwuity Matrix homeserver";

    package = mkPackageOption pkgs "matrix-continuwuity" { };

    serverName = mkOption {
      type = types.nonEmptyStr;
      example = "example.org";
      description = ''
        The server_name is the name of this server. It is used as a
        suffix for user and room ids.
      '';
    };

    allowRegistration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether new users can register on this server.
        Registration with token requires a `registration_token` to be
        set in `settings.global`.
      '';
    };

    allowFederation = mkOption {
      type = types.bool;
      default = true;
      description = "Whether this server federates with other servers.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Extra continuwuity.toml settings, merged on top of the values
        derived from the other options of this module.
        Refer to <https://continuwuity.org/configuration.html> for
        supported values (e.g. `{ global.registration_token = "..."; }`).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-continuwuity = {
      enable = true;
      inherit (cfg) package;

      settings = lib.mkMerge [
        {
          global = {
            server_name = cfg.serverName;
            allow_registration = cfg.allowRegistration;
            allow_federation = cfg.allowFederation;
          };
        }
        cfg.settings
      ];
    };
  };
}