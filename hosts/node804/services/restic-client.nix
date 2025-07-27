{ pkgs, config, ... }:
{
  sops = {
    secrets = {
      "repository/gotham/password" = {
        sopsFile = ../../../secrets/node804/restic.yaml;
        mode = "0444";
        owner = "restic";
        group = "users";
      };

      "backups/immich/password" = {
        sopsFile = ../../../secrets/node804/restic.yaml;
        mode = "0400";
        owner = "restic";
        group = "users";
      };

      "backups/immich/repository" = {
        sopsFile = ../../../secrets/node804/restic.yaml;
        mode = "0400";
        owner = "restic";
        group = "users";
      };
    };

    templates = {
      "gotham-environment" = {
        content = ''
          RESTIC_PASSWORD_FIlE="${config.sops.secrets."repository/gotham/password".path}"
          RESTIC_REST_USERNAME=node804
        '';
        owner = "restic";
        group = "users";
        mode = "0400";
      };
    };
  };

  services.restic.backups = {
    immich = {
      user = "restic";
      package = pkgs.writeShellScriptBin "restic" ''
        exec /run/wrappers/bin/restic "$@"
      '';

      initialize = true;

      repository = "rest:https://node804:@restic.gotham.checks.top/immich";
      # repositoryFile = config.sops.secrets."backups/immich/repository".path;
      passwordFile = config.sops.secrets."backups/immich/password".path;

      # Environment for HTTP auth
      environmentFile = config.sops.templates."gotham-environment".path;

      paths = [ 
        "/mnt/molasses/private-media/"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "4h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 2"
      ];

      checkOpts = [
        "--read-data-subset=10%"
        "--check-unused"
      ];
    };
  };

  users.users.restic = {
    isNormalUser = true;
    group = "users";
  };

  security.wrappers.restic = {
    source = "${pkgs.restic.out}/bin/restic";
    owner = "restic";
    group = "users";
    permissions = "u=rwx,g=,o=";
    capabilities = "cap_dac_read_search=+ep";
  };
}
