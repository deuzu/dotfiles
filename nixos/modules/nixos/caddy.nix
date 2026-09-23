{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.caddy;
in
{
  options.modules.caddy = with lib; {
    enable = mkEnableOption "Caddy web server / reverse proxy";

    email = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Email address used for ACME certificate issuance
        (expiry/revocation notices from the CA). Leave null to omit.
      '';
    };

    virtualHosts = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Virtual hosts to serve, passed through to
        {option}`services.caddy.virtualHosts`.
        Keys are hostnames, values are submodules
        (e.g. `{ extraConfig = "reverse_proxy 127.0.0.1:8080"; }`).
      '';
      example = {
        "example.org".extraConfig = ''
          root * /srv/www
          file_server
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      inherit (cfg) email virtualHosts;
    };
  };
}