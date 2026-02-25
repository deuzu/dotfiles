# NixOS

## Installation

[qfpl.io/posts/installing-nixos/](https://qfpl.io/posts/installing-nixos/)
or
[nix-community/NixOS-WSL](https://github.com/nix-community/NixOS-WSL)

## Setup

```shell
nix-shell -p git git-crypt gnupg pinentry-tty age sops ssh-to-age

mkdir -p ~/.config
git clone https://github.com/deuzu/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

mkdir ~/.gnupg
echo "pinentry-program $(which pinentry-tty)" > ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
gpg --armor --allow-secret-key-import --import <path/to/gpg.key>
git-crypt unlock

mkdir -p ~/.config/sops/age
cp <path/to/age/keys.txt> ~/.config/sops/age/keys.txt

sudo nixos-rebuild switch --flake ~/.config/dotfiles/nixos#<host>
```
