{ pkgs }:

with pkgs;
mkShell {
  nativeBuildInputs = [
    python3
    uv
  ];
}
