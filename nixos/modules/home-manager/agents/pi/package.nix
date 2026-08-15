{ lib
, buildNpmPackage
, fetchFromGitHub
, fetchurl
, pkg-config
, python3
, makeWrapper
, pixman
, cairo
, pango
, libpng
, giflib
, librsvg
, nodejs
}:

let
  aiDataTarball = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.84.2.tgz";
    hash = "sha256-AmJ4Wnaw6y7sWWzYp6su4j7vidLvG7EhHE8KGUTaz0E=";
  };
in
buildNpmPackage {
  pname = "pi-coding-agent";
  version = "0.84.2";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v0.84.2";
    hash = "sha256-d29ft9otYxdHRWYIAX8KMHPpppToX9ME5LbPb1rPcYo=";
  };

  npmDepsHash = "sha256-6J5Efe+6ptCuR3VZojwYPZO8BBnnZsOQ4OAeB64uYOY=";

  postPatch = ''
    mkdir -p /tmp/ai-tarball
    tar -xzf ${aiDataTarball} -C /tmp/ai-tarball
    mkdir -p packages/ai/src/providers/data
    cp -r /tmp/ai-tarball/package/dist/providers/data/. packages/ai/src/providers/data/
    rm -rf /tmp/ai-tarball
    substituteInPlace packages/ai/package.json \
      --replace-fail "npm run generate-models && npm run build:offline" "tsgo -p tsconfig.build.json && shx rm -rf dist/providers/data && shx cp -r src/providers/data dist/providers/data"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/pi-monorepo
    cp -r . $out/lib/node_modules/pi-monorepo/
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/pi \
      --add-flags "$out/lib/node_modules/pi-monorepo/packages/coding-agent/dist/cli.js"
    runHook postInstall
  '';

  nativeBuildInputs = [
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [
    pixman
    cairo
    pango
    libpng
    giflib
    librsvg
  ];

  meta = with lib; {
    description = "Pi - minimal terminal coding agent harness";
    homepage = "https://pi.dev";
    license = licenses.mit;
    mainProgram = "pi";
  };
}
