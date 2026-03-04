{
  imports = [
    ./agents/goose
    ./agents/opencode
    ./agents/skills

    ./browsers/chromium.nix
    ./browsers/firefox.nix
    ./browsers/librewolf.nix
    ./browsers/zen-browser.nix

    ./dev/go.nix
    ./dev/nodejs.nix
    ./dev/postman.nix
    ./dev/python.nix
    ./dev/rust.nix

    ./devops/ansible.nix
    ./devops/awscli.nix
    ./devops/dive.nix
    ./devops/google-cloud-sdk.nix
    ./devops/k9s.nix
    ./devops/krr.nix
    ./devops/kubectl.nix
    ./devops/packer.nix
    ./devops/postgresql.nix
    ./devops/tenv.nix

    ./display/stylix.nix
    ./display/gnome.nix
    ./display/hyprland.nix
    ./display/niri.nix
    ./display/hypridle.nix
    ./display/hyprlock.nix
    ./display/dunst.nix
    ./display/waybar.nix
    ./display/wofi.nix

    ./shells/bash.nix
    ./shells/nushell.nix

    ./terminals/ghostty.nix
    ./terminals/wezterm.nix
    ./terminals/zellij.nix

    ./text-editors/helix.nix
    ./text-editors/vscode.nix
    ./text-editors/zed.nix

    ./vcs/git.nix
    ./vcs/jj.nix

    ./acli.nix
    ./anytype.nix
    ./arandr.nix
    ./at.nix
    ./atuin.nix
    ./bat.nix
    ./bottom.nix
    ./btop.nix
    # ./calibre.nix # build fails
    ./carapace.nix
    ./curl.nix
    ./direnv.nix
    ./dua.nix
    ./env.nix
    ./gcc.nix
    ./gh.nix
    ./git-crypt.nix
    ./gpg.nix
    ./httpie.nix
    ./jq.nix
    ./libreoffice.nix
    ./make.nix
    ./protonvpn.nix
    ./ripgrep.nix
    ./serpl.nix
    ./signal.nix
    ./slack.nix
    ./ssh.nix
    ./starship.nix
    ./tailscale.nix
    ./tealdeer.nix
    ./vlc.nix
    ./wget.nix
    ./which.nix
    ./whisper.nix
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
