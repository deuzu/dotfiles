{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.matrix-rtc;
  format = pkgs.formats.yaml { };
  livekitConfig = format.generate "livekit.yaml" {
    port = cfg.signalPort;
    rtc = {
      tcp_port = cfg.rtcTcpPort;
      port_range_start = cfg.udpPortRange.from;
      port_range_end = cfg.udpPortRange.to;
      use_external_ip = true;
    };
    room.auto_create = false; # rooms must be created with a valid JWT
  };
in
{
  options.modules.matrix-rtc = with lib; {
    enable = mkEnableOption "MatrixRTC backend (LiveKit SFU + lk-jwt-service) for Element Call";

    keyFile = mkOption {
      type = types.path;
      description = ''
        File containing the LiveKit credentials as `<key-name>: <secret>`
        (one line). Shared by livekit-server (`--key-file`) and
        lk-jwt-service (`LIVEKIT_KEY_FILE`), both expect the same format.
      '';
    };

    livekitUrl = mkOption {
      type = types.strMatching "^wss?://.*";
      example = "wss://livekit.touya.cc";
      description = "Public WebSocket URL of the LiveKit SFU.";
    };

    fullAccessHomeservers = mkOption {
      type = types.nonEmptyStr;
      example = "touya.cc";
      description = ''
        server_name(s) whose users receive full LiveKit access
        (LIVEKIT_FULL_ACCESS_HOMESERVERS). Upstream defaults to wildcard (*).
      '';
    };

    jwtPort = mkOption {
      type = types.port;
      default = 8080;
      description = "Port lk-jwt-service listens on (loopback, behind Caddy).";
    };

    signalPort = mkOption {
      type = types.port;
      default = 7880;
      description = "Port livekit-server HTTP/WS listens on (loopback, behind Caddy).";
    };

    rtcTcpPort = mkOption {
      type = types.port;
      default = 7881;
      description = "WebRTC ICE/TCP fallback port. Must be reachable from outside.";
    };

    udpPortRange = mkOption {
      type = types.submodule {
        options = {
          from = mkOption {
            type = types.port;
            description = "Start of the UDP media port range.";
          };
          to = mkOption {
            type = types.port;
            description = "End of the UDP media port range.";
          };
        };
      };
      default = {
        from = 50100;
        to = 50200;
      };
      example = {
        from = 50100;
        to = 50200;
      };
      description = "UDP port range for WebRTC media. Must be reachable from outside.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.livekit = {
      isSystemUser = true;
      group = "livekit";
      home = "/var/lib/livekit";
    };
    users.groups.livekit = { };

    services.lk-jwt-service = {
      enable = true;
      inherit (cfg) keyFile;
      livekitUrl = cfg.livekitUrl;
      port = cfg.jwtPort;
    };
    systemd.services.lk-jwt-service = {
      # The key file is rendered by sops-nix at activation time.
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
      # Restrict full access to our own server_name (upstream default is "*").
      environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = cfg.fullAccessHomeservers;
    };

    systemd.services.livekit = {
      description = "LiveKit SFU for MatrixRTC";
      documentation = [ "https://github.com/livekit/livekit" ];
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "sops-nix.service"
      ];
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.livekit} --config ${livekitConfig} --key-file ${toString cfg.keyFile}";
        User = "livekit";
        Group = "livekit";
        StateDirectory = "livekit";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictRealtime = true;
        LockPersonality = true;
      };
    };
  };
}
