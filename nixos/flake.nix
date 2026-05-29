{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    # nixpkgs-anytype.url = "github:nixos/nixpkgs/70b191e2e0b1b5fe8586ad939dfa01f3047865f7";
    nixpkgs-anytype.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, home-manager, nixos-wsl, sops-nix, agent-skills, ... } @inputs:
    {
      nixosConfigurations =
        let
          system = "x86_64-linux";
          myLib = import ./lib { inherit (nixpkgs) lib; };
          mkHost = host: user: extraModules: nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs system myLib; };
            modules = [
              ./hosts/${host}
              ./overlays.nix
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  extraSpecialArgs = { inherit inputs system myLib; };
                  users.${user} = import ./hosts/${host}/users/${user}.nix;
                  sharedModules = [ sops-nix.homeManagerModules.sops agent-skills.homeManagerModules.default ];

                };
              }
            ] ++ extraModules;
          };
        in
        {
          workstation = mkHost "workstation" "ftouya" [ ];
          home-wsl = mkHost "home-wsl" "ftouya" [ nixos-wsl.nixosModules.default ];
        };
    } // flake-utils.lib.eachDefaultSystem (system:
      {
        devShells = { };
      }
    );
}
