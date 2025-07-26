{ inputs, nixpkgs, nixpkgs-unstable, home-manager, ... }:
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    ../common/core/sops.nix
    ../common/core/openssh.nix
    ../common/core/flakes.nix
    ../../users/harkunwar.nix
    ./configuration.nix
    ./services/wireguard-client.nix
    # ./services/restic-client.nix
    # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
    # Make unstable packages available
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

