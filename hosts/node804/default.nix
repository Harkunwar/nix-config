{ inputs, nixpkgs, nixpkgs-unstable, home-manager, ... }:
nixpkgs.lib.nixosSystem rec {
  pkgs = import nixpkgs { inherit system; };
  pkgs-unstable = import nixpkgs-unstable { inherit system; };
  system = "x86_64-linux";
  specialArgs = { inherit pkgs-unstable; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    ../common/core/sops.nix
    ./configuration.nix
    ./services/pocketid.nix
    ./services/caddy.nix
    # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
  ];
}

