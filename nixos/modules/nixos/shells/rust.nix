{ pkgs }:

with pkgs;
mkShell {
  nativeBuildInputs = [
    cargo
    rust-analyzer-unwrapped
    rustPackages.clippy
    rustc
    rustfmt
    # dependencies
    openssl
    pkg-config
  ];
}
