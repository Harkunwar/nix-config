{ pkgs, config, ... }:
{

  #   users.users.restic = {
  #     isNormalUser = true;
  #   };
  #   
  #   security.wrappers.restic = {
  #     source = "${pkgs.restic.out}/bin/restic";
  #     owner = "restic";
  #     group = "users";
  #     permissions = "u=rwx,g=,o=";
  #     capabilities = "cap_dac_read_search=+ep";
  #   };

  services.restic = {
    server = {
      enable = true;
      prometheus = true;
      dataDir = /mnt/backup/restic;
      listenAddress = "8198";
    };
  };
}
