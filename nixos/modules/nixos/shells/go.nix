{ pkgs }:

with pkgs;
mkShell {
  nativeBuildInputs = [
    go
  ];

  # shellHook = ''
  # '';
}
