{ pkgs }:

with pkgs;
mkShell {
  nativeBuildInputs = [
    nodejs
    pnpm
  ];
}
