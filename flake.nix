{
  description = "Harkunwar's Nix Configuration";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that saw how to build software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Manages configs and links them to your home directory
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Partitioning and disk management tool
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Provides a way to manage secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ nixpkgs, home-manager, sops-nix, darwin, nixpkgs-unstable, disko, self, ... }: {

    nixosConfigurations = {
      # This is the NixOS configuration for the Node804 server
      # It imports the configuration from the hosts/node804 directory
      node804 = import ./hosts/node804 {
        inherit inputs nixpkgs nixpkgs-unstable home-manager;
      };

      # This is the NixOS configuration for the GMKTeck NucBox G3 Plus server
      # It imports the configuration from the hosts/nucboxg3 directory
      nucboxg3 = import ./hosts/nucboxg3 {
        inherit inputs nixpkgs nixpkgs-unstable disko;
      };

      # This is the NixOS configuration for the Racknerd server
      # It imports the configuration from the hosts/racknerd directory
      racknerd = import ./hosts/racknerd {
        inherit inputs nixpkgs nixpkgs-unstable;
      };

      # This is the NixOS configuration for the DediRock Krypton Tank
      # It imports the configuration from the hosts/gotham directory
      gotham = import ./hosts/gotham {
        inherit inputs nixpkgs nixpkgs-unstable disko;
      };
    };

    # This is the Darwin configuration for the Macbook Pro 14
    # It imports the configuration from the hosts/macbook-pro-14 directory
    darwinConfigurations.MacbookPro14 = import ./hosts/macbook-pro-14 {
      inherit inputs nixpkgs home-manager darwin;
    };
  };
}
