{ inputs, nixpkgs, home-manager, sops-nix ... }:
nixpkgs.lib.nixosSystem rec {
  pkgs = import nixpkgs { inherit system; };
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    sops-nix.nixosModules.sops
    # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
  ];
}

