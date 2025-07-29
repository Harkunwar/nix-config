{ pkgs, config, ... }:
{

  sops = {
    secrets = {
      "node804-restic-htpasswd" = {
        sopsFile = ../../../secrets/gotham/node804.yaml;
        mode = "0444";
      };

      "racknerd-restic-htpasswd" = {
        sopsFile = ../../../secrets/gotham/racknerd.yaml;
        mode = "0444";
      };
    };

    templates = {
      ".htpasswd-restic-server" = {
        content = ''
          node804:${config.sops.placeholder."node804-restic-htpasswd"}
          racknerd:${config.sops.placeholder."racknerd-restic-htpasswd"}
        '';
        path = "/etc/restic/.htpasswd";
        owner = "restic";
        group = "restic";
      };
    };
  };

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
