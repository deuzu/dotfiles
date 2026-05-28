{ lib }:

let
  imports = [
    ./landrun.nix
    ./bwrap.nix
    ./folder.nix
  ];
in
lib.foldl (acc: path: acc // (import path { inherit lib; })) { } imports
