{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.caddy;
in {
  options.modules.caddy = {
    enable = mkEnableOption "Caddy reverse proxy";
    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            description = "The backend port to proxy to.";
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Extra Caddy configuration for this virtual host.";
          };
        };
      });
      default = {};
      description = "Virtual hosts to configure in Caddy.";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = mapAttrs (name: hostCfg: {
        extraConfig = ''
          reverse_proxy localhost:${toString hostCfg.port}
          ${hostCfg.extraConfig}
        '';
      }) cfg.virtualHosts;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
