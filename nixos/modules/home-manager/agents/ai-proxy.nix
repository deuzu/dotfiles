{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.agents.ai-proxy;

  mkCaddyRoute = { path, host, apiKey, headerFormat }: ''
    handle_path ${path}* {
      reverse_proxy https://${host} {
        header_up ${builtins.replaceStrings [ "%s" ] [ "{file.{$CREDENTIALS_DIRECTORY}/${apiKey}}" ] headerFormat}
        header_up Host ${host}
      }
    }
  '';

  caddyRoutesString = concatMapStrings (route: mkCaddyRoute { inherit (route) path host apiKey headerFormat; }) cfg.routes;

  caddyfile = pkgs.writeText "Caddyfile-ai-proxy" ''
    {
      admin off
      auto_https off
    }
    http://127.0.0.1:${toString cfg.port} {
      ${caddyRoutesString}
      
      respond "Not Found" 404
    }
  '';

  systemdCredentials = mapAttrsToList (name: path: "${name}:${path}") cfg.secrets;

in
{
  options.modules.agents.ai-proxy = {
    enable = mkEnableOption "Enable local API proxy for AI agents via Caddy";

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Port for the dedicated user-level Caddy proxy.";
    };

    secrets = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Map of Environment Variable names to files containing the secret values.";
    };

    routes = mkOption {
      type = types.listOf (types.submodule {
        options = {
          path = mkOption { type = types.str; example = "/openai"; };
          host = mkOption { type = types.str; example = "api.openai.com"; };
          apiKey = mkOption { type = types.str; example = "OPENAI_API_KEY"; };
          headerFormat = mkOption {
            type = types.str;
            default = "Authorization \"Bearer %s\"";
            description = "Format string for the header, where %s is replaced with the secret value.";
          };
        };
      });
      default = [ ];
      description = "List of API routes to proxy securely.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.ai-proxy = {
      Unit = {
        Description = "Dedicated Caddy Proxy for AI Agents";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${pkgs.caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile";
        ExecReload = "${pkgs.caddy}/bin/caddy reload --config ${caddyfile} --adapter caddyfile";
        Restart = "on-failure";
        LoadCredential = systemdCredentials;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.sessionVariables = {
      OPENAI_BASE_URL = "http://127.0.0.1:4000/openai/v1";
      MISTRAL_BASE_URL = "http://127.0.0.1:4000/mistral/v1";
      GOOGLEAI_BASE_URL = "http://127.0.0.1:4000/google/v1beta";
    };
  };
}
