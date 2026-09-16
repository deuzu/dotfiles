{ pkgs, config, lib, ... }:
let
  cfg = config.modules.networking;
in
{
  options.modules.networking = with lib; {
    enable = mkEnableOption "Networking";

    hostName = mkOption {
      type = types.str;
      default = builtins.head (builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users));
      description = "Machine hostname. Defaults to the first normal user's name.";
    };

    firewall = {
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        example = [ 22 443 ];
        description = "TCP ports to open in the firewall.";
      };

      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        example = [ 51820 ];
        description = "UDP ports to open in the firewall.";
      };
    };

    networkmanager = {
      plugins = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression "[ pkgs.networkmanager-openvpn ]";
        description = "NetworkManager plugins to install.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      inherit (cfg) hostName;
      networkmanager = {
        enable = true;
        inherit (cfg.networkmanager) plugins;
      };
      firewall = {
        inherit (cfg.firewall) allowedTCPPorts allowedUDPPorts;
      };
    };
  };
}