{ config, ... }:
{
  sops = {
    defaultSopsFile = ./ftouya.secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
