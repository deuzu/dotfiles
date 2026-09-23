{ ... }: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."matrix-rtc-livekit-keys" = {
      owner = "livekit";
      group = "livekit";
      mode = "0400";
    };
  };
}
