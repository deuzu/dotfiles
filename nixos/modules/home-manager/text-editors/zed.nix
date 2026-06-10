{ config, lib, ... }:
let
  cfg = config.modules.textEditors.zed;
in
{
  options.modules.textEditors.zed = with lib; {
    enable = mkEnableOption "Zed Text Editor";
  };

  config = lib.mkIf cfg.enable {
    targets.genericLinux.nixGL.vulkan.enable = true;
    programs.zed-editor = {
      enable = true;
      extensions = [
        "env"
        "nix"
        "sql"
      ];
      userSettings = {
        assistant = {
          enabled = true;
          default_model = {
            provider = "openai";
            model = "gpt-4o";
          };
          edit_predictions = {
            mode = "subtle";
          };
        };
        context_servers = {
          # mcp-product = {
          #   command = {
          #     path = "";
          #     args = [];
          #     # "env" = {};
          #   };
          #   # "settings" = {};
          # };
        };
        file_scan_exclusions = [
          "**/.git"
          "**/.svn"
          "**/.hg"
          "**/.jj"
          "**/.terraform"
        ];
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      };
    };
  };
}
