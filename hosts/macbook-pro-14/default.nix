{ inputs, nixpkgs, home-manager, darwin, ... }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
  modules = [
    ../../modules/darwin
    home-manager.darwinModules.home-manager
    {
      users.users.harkunwar.home = "/Users/harkunwar";
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.harkunwar.imports = [ ../../modules/home-manager ];
      };
    }
  ];
}
