{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.modules.display.stylix;
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  
  options.modules.display.stylix = with lib; {
    enable = mkEnableOption "Stylix Theme";
    wallpaper = mkOption {
      type = types.nullOr (types.path);
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = with pkgs; {
      # With home-manager.useGlobalPkgs = true, nixpkgs options are disabled in
      # the HM context. Stylix's HM module defines nixpkgs.overlays via autoloaded
      # target overlays (nixos-icons, gtksourceview, ...), which trips HM's
      # assertion. These overlays had no effect under useGlobalPkgs anyway,
      # so disable them explicitly.
      overlays.enable = false;

      enable = true;
      autoEnable = true;

      # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/README.md
      # base16Scheme = "${base16-schemes}/share/themes/silk-dark.yaml";
      # base16Scheme = "${base16-schemes}/share/themes/catppuccin-mocha.yaml";
      base16Scheme = "${base16-schemes}/share/themes/rose-pine-moon.yaml";

      image = cfg.wallpaper;

      polarity = "dark";

      cursor = {
        # package = bibata-cursors;
        # name = "Bibata-Modern-Ice";
        # size = 16;
        package = rose-pine-cursor;
        name = "BreezeX-RosePineDawn-Linux";
        size = 20;
      };

      fonts = {
        monospace = {
          package = maple-mono.NF;
          name = "Maple Mono NF";
          # package = nerd-fonts.fira-code;
          # name = "FiraCode Nerd Font";
          # package = nerd-fonts.monaspace;
          # name = "MonaspiceNe Nerd Font Mono";
        };
        sansSerif = {
          package = dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = dejavu_fonts;
          name = "DejaVu Serif";
        };
      };
    };

    # Needed for WSL
    home.packages = with pkgs; [ dconf ];
  };
}
