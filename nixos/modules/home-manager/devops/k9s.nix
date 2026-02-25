{ config, lib, pkgs, ... }:
let
  cfg = config.modules.devops.k9s;
in
{
  options.modules.devops.k9s = with lib; {
    enable = mkEnableOption "K9s Kubernetes Cluster Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.k9s = {
      package = pkgs.k9s;
      enable = true;

      aliases = {
        aliases = {
          dp = "deployments";
          sec = "v1/secrets";
          jo = "jobs";
        };
      };

      plugins = {
        # krr = {
        #   shortCut = "Shift-K";
        #   description = "Get krr";
        #   scopes = ["deployments" "daemonsets" "statefulsets" "cronjobs"];
        #   command = "bash";
        #   background = false;
        #   confirm = false;
        #   args = [
        #     "-c"
        #     ''
        #       LABELS=$(kubectl get $RESOURCE_NAME $NAME -n $NAMESPACE --context $CONTEXT --show-labels | awk '{print $NF}' | awk '{if(NR>1)print}')
        #       ${krr} simple --cluster $CONTEXT --selector $LABELS -p http://127.0.0.1:9090
        #       echo "Press 'q' to exit"
        #       while : ; do
        #       read -n 1 k <&1
        #       if [[ $k = q ]] ; then
        #       break
        #       fi
        #       done
        #     ''
        #   ];
        # };
      };
    };

    # Package is broken 😢
    # home.packages = with pkgs; [ krr ];
  };
}
