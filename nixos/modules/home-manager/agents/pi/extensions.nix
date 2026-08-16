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

  # Bundle subagents extension
  esbuild src/subagents.ts \
    --bundle \
    --platform=node \
    --format=esm \
    --outfile=$out/subagents.js \
    --external:@earendil-works/* \
    --external:typebox \
    --external:node:*

  # Copy permissions extension
  cp src/permissions.ts $out/permissions.ts
''
