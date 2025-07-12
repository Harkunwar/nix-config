{ inputs, nixpkgs, nixpkgs-unstable, home-manager, ... }:
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
  pkgs-unstable = import nixpkgs-unstable { inherit system; };
  nixpkgs.overlays = [
    (self: super: {
      pocket-id = pkgs-unstable.pocket-id;
    })
  ];
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

