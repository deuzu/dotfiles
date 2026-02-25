{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.gcloud;
in
{
  options.modules.devops.gcloud = with lib; {
    enable = mkEnableOption "GCloud";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]))
    ];
  };
}
