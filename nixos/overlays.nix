{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      anytype = final.stable.anytype;
    })
  ];
}
