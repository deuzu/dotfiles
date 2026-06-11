{ config, lib, ... }:

let
  cfg = config.modules.ponos;
in
{
  options.modules.ponos = {
    instances = lib.mkOption {
      default = { };
      description = "Ponos instances configuration";
      type = lib.types.attrsOf lib.types.anything;
    };
  };

  config = {
    programs.ponos.instances = cfg.instances;
  };
}
