{ pkgs }:

pkgs.runCommand "pi-extensions"
{
  nativeBuildInputs = [ pkgs.esbuild ];
}
''
  mkdir -p $out
  mkdir -p src
  cp -r ${./extensions}/* src/

  # Bundle rpi extension
  mkdir -p $out/rpi
  esbuild src/rpi/index.ts \
    --bundle \
    --platform=node \
    --format=esm \
    --outfile=$out/rpi/index.js \
    --external:@earendil-works/* \
    --external:typebox \
    --external:node:*

  # Bundle permissions extension
  mkdir -p $out/permissions
  esbuild src/permissions/index.ts \
    --bundle \
    --platform=node \
    --format=esm \
    --outfile=$out/permissions/index.js \
    --external:@earendil-works/* \
    --external:typebox \
    --external:shell-quote \
    --external:node:*
''
