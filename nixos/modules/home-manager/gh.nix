{ config, lib, pkgs, ... }:
let
  cfg = config.modules.gh;
in
{
  options.modules.gh = with lib; {
    enable = mkEnableOption "Github CLI Tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
    ];

    home.activation.ghExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ${pkgs.gh}/bin/gh auth status &>/dev/null; then
        if ! ${pkgs.gh}/bin/gh extension list 2>/dev/null | grep -q "agynio/gh-pr-review"; then
          ${pkgs.gh}/bin/gh extension install agynio/gh-pr-review
          echo "gh-pr-review extension installed"
        fi
      fi
    '';
  };
}
