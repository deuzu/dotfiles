{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

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
  };

  outputs = { nixpkgs, flake-utils, home-manager, nixos-wsl, sops-nix, ... } @inputs:
    {
      nixosConfigurations =
        let
          system = "x86_64-linux";
          mkHost = host: user: extraModules: nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs system; };
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
                  extraSpecialArgs = { inherit inputs system; };
                  users.${user} = import ./hosts/${host}/users/${user}.nix;
                  sharedModules = [ sops-nix.homeManagerModules.sops ];
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
