{ inputs, nixpkgs, ... }:
nixpkgs.lib.nixosSystem rec {
  pkgs = import nixpkgs { inherit system; };
  system = "x86_64-linux";
  modules = [
    inputs.sops-nix.nixosModules.sops
    ../common/core/sops.nix
    ./configuration.nix
    # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
  ];
}

