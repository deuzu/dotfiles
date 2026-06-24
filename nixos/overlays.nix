{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      anytype = (import inputs.nixpkgs-anytype {
        inherit system;
        config.allowUnfree = true;
      }).anytype;
    })
    inputs.niri.overlays.niri
    inputs.neru.overlays.default
  ];
}
