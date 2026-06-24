{ config, lib, ... }:
let
  cfg = config.modules.env;
  bashEnabled = config.modules.shell.bash.enable;
  # nushellEnabled = config.modules.shell.nushell.enable;
in
{
  options.modules.env = with lib; {
    vars = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
    secrets = mkOption {
      type = types.attrsOf types.path;
      default = { };
    };
  };

  config =
    let
      envs = lib.concatStringsSep "\n" (lib.mapAttrsToList
        (name: path: ''
          export ${name}="$(cat "${toString path}")"
        '')
        cfg.secrets);
    in
    {
      home.sessionVariables = lib.mapAttrs (name: val: toString val) cfg.vars;

      programs.bash.initExtra = lib.mkIf bashEnabled envs;
      # programs.nushell.extraEnv = lib.mkIf nushellEnabled envs;
    };
}
