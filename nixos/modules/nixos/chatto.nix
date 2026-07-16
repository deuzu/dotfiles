{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.chatto;
  
  chattoPkg = pkgs.stdenv.mkDerivation rec {
    pname = "chatto";
    version = "0.4.11";

    src = pkgs.fetchurl {
      url = "https://github.com/chattocorp/chatto/releases/download/v${version}/chatto_Linux_x86_64.tar.gz";
      sha256 = "sha256-CuYmBuDKe/SOJS/JB/CP8LSYzpDKgM0xzSvFfYjekPo=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    setSourceRoot = "sourceRoot=.";

    installPhase = ''
      mkdir -p $out/bin
      cp chatto $out/bin/
      chmod +x $out/bin/chatto
    '';
  };

in {
  options.modules.chatto = {
    enable = mkEnableOption "Chatto";
    port = mkOption {
      type = types.port;
      default = 3000;
      description = "The port Chatto will listen on.";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/chatto";
      description = "The directory where Chatto stores its data.";
    };
  };

  config = mkIf cfg.enable {
    users.users.chatto = {
      isSystemUser = true;
      group = "chatto";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.chatto = {};

    systemd.services.chatto = {
      description = "Chatto Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${chattoPkg}/bin/chatto run --port ${toString cfg.port}";
        WorkingDirectory = cfg.dataDir;
        User = "chatto";
        Group = "chatto";
        Restart = "always";
        StateDirectory = "chatto";
      };
      
      environment = {
        # Add any environment variables here
      };
    };
  };
}
