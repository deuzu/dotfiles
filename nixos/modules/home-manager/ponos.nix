{ config, lib, ... }:

let
  cfg = config.modules.ponos;
in
{
  options.modules.ponos = {
    instances = lib.mkOption {
      default = { };
      description = "Ponos instances configuration";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this ponos instance";
          };
          settings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Settings for the ponos instance";
          };
        };
      });
    };
  };

  config = {
    services.ponos.instances = cfg.instances;
  };
}
