{ lib }:

{
  folder = pkgs: srcDir: destDir: vars:
    builtins.listToAttrs (map
      (file: {
        name = "${destDir}/${file}";
        value.text = builtins.readFile (pkgs.replaceVars (srcDir + "/${file}") vars);
      })
      (builtins.attrNames (lib.filterAttrs (name: type: type == "regular") (builtins.readDir srcDir))));
}
