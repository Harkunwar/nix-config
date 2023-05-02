{
  description = "My Macbook Pro 15 Flake";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that saw how to build software
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22-11


    # Manages configs and links them to your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, self, ... }: {
    # .mac at the end is my computer name
    darwinConfigurations.mac =
      darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        pkgs = import nixpkgs { system = "x86_64-darwin"; config.allowUnfree = true; };
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.harkunwar.imports = [ ./modules/home-manager ];
            };
          }
        ];
      };
  };
}
