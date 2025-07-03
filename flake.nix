{
  description = "My Macbook Pro Flake";
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
    nixosConfigurations.node804 = nixpkgs.lib.nixosSystem rec {
      pkgs = import nixpkgs { inherit system; };
      system = "x86_64-linux";
      modules = [ ./configuration.nix
                  # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
                  ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
                ];
    };
    # MacBookPro15 at the end is my computer name
    darwinConfigurations.MacbookPro14 =
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            users.users.harkunwar.home = "/Users/harkunwar";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.harkunwar.imports = [ ./modules/home-manager ];
            };
          }
        ];
      };
    darwinConfigurations.MacBookPro15 =
      darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        pkgs = import nixpkgs { system = "x86_64-darwin"; config.allowUnfree = true; };
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            users.users.harkunwar.home = "/Users/harkunwar";
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
