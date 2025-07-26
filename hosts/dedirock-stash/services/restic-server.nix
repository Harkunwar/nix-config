{ pkgs, config, ... }:
{

  sops = {
    secrets = {
      "node804-restic-htpasswd" = {
        sopsFile = ../../../secrets/dedirock-stash/node804.yaml;
        mode = "0444";
      };

      "racknerd-restic-htpasswd" = {
        sopsFile = ../../../secrets/dedirock-stash/racknerd.yaml;
        mode = "0444";
      };
    };

    templates = {
      ".htpasswd-restic-server" = {
        content = ''
          node804:${config.sops.placeholder."node804-restic-htpasswd"}
          racknerd:${config.sops.placeholder."racknerd-restic-htpasswd"}
        '';
        owner = "restic";
        group = "restic";
      };
    };
  };


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
      dataDir = "/mnt/backup/restic";
      listenAddress = "7782";
      htpasswd-file = config.sops.templates.".htpasswd-restic-server".path;
    };
  };
}
