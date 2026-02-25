{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev.rust;
in
{
  options.modules.dev.rust = with lib; {
    enable = mkEnableOption "Rust";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cargo
      rust-analyzer-unwrapped
      rustPackages.clippy
      rustc
      rustfmt
    ];
  };
}
