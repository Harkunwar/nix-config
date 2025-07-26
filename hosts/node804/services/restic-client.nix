{ pkgs, config, ... }:
{
  sops = {
    secrets = {
      "restic-repository-password" = {
        sopsFile = ../../../secrets/node804-restic.yaml;
        mode = "0400";
        owner = "root";
        group = "root";
      };

      "restic-http-auth" = {
        sopsFile = ../../../secrets/gotham/node804.yaml;
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };

  services.restic.backups = {
    daily = {
      repository = "rest:http://node804:@gotham.local:7782/node804";
      passwordFile = config.sops.secrets."restic-repository-password".path;
      
      # Set HTTP authentication
      extraOptions = [
        "--option"
        "rest.connections=10"
      ];

      # Environment for HTTP auth
      environmentFile = pkgs.writeText "restic-env" ''
        RESTIC_REST_USERNAME=node804
      '';

      # Use a script wrapper to handle HTTP password
      backupPrepareCommand = ''
        export RESTIC_REST_PASSWORD="$(cat ${config.sops.secrets."restic-http-auth".path})"
      '';

      paths = [
        "/home"
        "/etc"
        "/var/lib"
        "/root"
      ];

      exclude = [
        "/home/*/.cache"
        "/home/*/.local/share/Trash"
        "/home/*/Downloads"
        "/var/lib/docker"
        "/var/lib/containers"
        "*.tmp"
        "*.swp"
        "*~"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--keep-yearly 1"
      ];

      checkOpts = [
        "--read-data-subset=5%"
      ];

      # Run initialization and prune after backup
      initialize = true;
      
      # Additional backup options
      extraBackupArgs = [
        "--compression=auto"
        "--exclude-caches"
        "--one-file-system"
      ];
    };
  };

  # Enable systemd timer for the backup
  systemd.timers.restic-backups-daily = {
    wantedBy = [ "timers.target" ];
  };

  # Optional: Add a backup health check script
  systemd.services.restic-backup-check = {
    description = "Check restic backup health";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "restic-check" ''
        set -eu
        export RESTIC_REPOSITORY="rest:http://node804:@gotham.local:7782/node804"
        export RESTIC_PASSWORD_FILE="${config.sops.secrets."restic-repository-password".path}"
        export RESTIC_REST_USERNAME="node804"
        export RESTIC_REST_PASSWORD="$(cat ${config.sops.secrets."restic-http-auth".path})"
        
        ${pkgs.restic}/bin/restic check --read-data-subset=1%
      '';
    };
  };

  systemd.timers.restic-backup-check = {
    description = "Run restic backup health check weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # Install restic package
  environment.systemPackages = with pkgs; [
    restic
  ];
}
