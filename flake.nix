{
  description = "Harkunwar's Nix Configuration";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that saw how to build software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Manages configs and links them to your home directory
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, self, ... }: {
    nixosConfigurations.node804 = import ./hosts/node804 {
      inherit inputs nixpkgs home-manager;
    };

    darwinConfigurations.MacbookPro14 = import ./hosts/macbook-pro-14 {
      inherit inputs nixpkgs home-manager darwin;
    };
  };
}
