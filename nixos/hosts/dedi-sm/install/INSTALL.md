# Runbook — Dedibox (Online.net): Debian 13 → NixOS via nixos-infect

```sh
export SERVER_IP=<server_ip>
```

## NixOS Installation

1. Install Debian on online.net console
2. Install prerequisites
```sh
apt-get update && apt-get install -y curl screen # or tmux
```
3. Copy the bootstrap file
```sh
scp nixos/hosts/dedi-sm/install/bootstrap-configuration.nix root@$SERVER_IP:/etc/nixos/configuration.nix
```
4. Install NixOS Infect
```sh
curl -o /root/nixos-infect https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect
```
5. Infect
```sh
NIXOS_CONFIG=/root/bootstrap.nix NO_REBOOT=1 bash -x /root/nixos-infect
```
6. Reboot
```sh
reboot
```

## NixOS Configuration

1. Copy hardware configuration from server
```sh
scp root@$SERVER_IP:/etc/nixos/hardware-configuration.nix nixos/hosts/dedi-sm/hardware-configuration.nix
```
2. Switch config
```sh
nixos-rebuild --target-host root@$SERVER_IP switch --flake ./nixos#dedi-sm
```
