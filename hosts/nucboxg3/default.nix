{ inputs, nixpkgs, nixpkgs-unstable, disko, ... }:
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
  specialArgs = { inherit inputs; };
  modules = [
    disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./filesystem/disko.nix
    ../common/core/sops.nix
    ../common/core/openssh.nix
    ../common/core/flakes.nix
    ../../users/harkunwar.nix
    ./home-assistant
    ./configuration.nix
    # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
     ({ config, pkgs, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    })
  ];
}

