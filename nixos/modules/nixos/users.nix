{ config, lib, ... }:
let
  cfg = config.modules.users;
in
{
  options.modules.users = with lib; {
    enable = mkEnableOption "Users";
    users = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };
          groups = mkOption {
            type = types.listOf (types.str);
            default = [ ];
          };
          home = mkOption {
            type = types.str;
            default = null;
          };
          uid = mkOption {
            type = types.int;
            default = 1000;
          };
          sshAuthorizedKeys = mkOption {
            type = types.listOf (types.str);
            default = [ ];
          };
          isNormalUser = mkOption {
            type = types.bool;
            default = true;
          };
        };
      });
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.users =
      builtins.listToAttrs (
        map
          (user: {
            name = user.name;
            value = {
              createHome = user.home != null;
              extraGroups = user.groups;
              group = "users";
              home = user.home;
              isNormalUser = user.isNormalUser;
              isSystemUser = !user.isNormalUser;
              uid = user.uid;
              openssh.authorizedKeys.keys = user.sshAuthorizedKeys;
            };
          })
          cfg.users
      );
  };
}
