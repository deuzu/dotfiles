{ pkgs }:

let
  plakar-latest = pkgs.buildGoModule rec {
    pname = "plakar";
    version = "1.1.4";

    src = pkgs.fetchFromGitHub {
      owner = "PlakarKorp";
      repo = "plakar";
      rev = "v${version}";
      hash = "sha256-Urj1BG3XGhSroaa9pl9NGiKj38J1P+H9sA7noGwIhdc=";
    };

    vendorHash = "sha256-aqHjSTVVxBbaHAZZNQaFbftN0Hbl/+7wgk5uFM664po=";

    doCheck = false;

    ldflags = [
      "-s"
      "-w"
      "-X github.com/PlakarKorp/plakar/cmd/plakar/version.Version=${version}"
    ];

    meta = with pkgs.lib; {
      description = "Encrypted, queryable backups for engineers based on an immutable data store and portable archives";
      homepage = "https://plakar.io/";
      license = licenses.isc;
      maintainers = [ ];
    };
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    plakar-latest
    go
    gnumake
  ];

  shellHook = ''
    echo "Plakar version: $(plakar version 2>/dev/null)"
    echo "Tools available: go, gnumake"
  '';
}
