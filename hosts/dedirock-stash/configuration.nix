{ modulesPath
, lib
, pkgs
, ...
} @ args:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./filesystem/disko.nix
  ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "dedirock-stash";

  system.stateVersion = "25.05";
}
