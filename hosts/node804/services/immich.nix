{ config, lib, pkgs, ... }:

{
  services.immich = {
    enable = true;
    openFirewall = true;
    port = 4664;
    accelerationDevices = null; # Set to null to enable all devices
    mediaLocation = "/mnt/molasses/private-media";
    group = "immich";
    host = "0.0.0.0";
  };
}
