{ config, pkgs, ... }:
let
  pocketidPort = 1441;
  pocketidDataDir = "/var/lib/pocketid";
  pocketidPackage = pkgs.unstable.pocket-id;
in
{
    sops = {
        secrets = {
            "MAXMIND_LICENSE_KEY".sopsFile = ../../../secrets/pocketid.yaml;
        };
        templates = {
            "pocketid-env".content = ''
                MAXMIND_LICENSE_KEY=${config.sops.placeholder."MAXMIND_LICENSE_KEY"}
                TRUST_PROXY=true
                PUBLIC_APP_URL=http://pocketid.lab.harkunwar.com
                PUBLIC_UI_CONFIG_DISABLED=false
                PORT=${toString pocketidPort}
                DATA_DIR=${pocketidDataDir}
            '';
        };
    };

    # Create pocketid user
    users.users.pocketid = {
        isSystemUser = true;
        group = "pocketid";
        home = pocketidDataDir;
        createHome = true;
    };
    users.groups.pocketid = {};

    # Create data directory with proper permissions
    systemd.tmpfiles.rules = [
        "d ${pocketidDataDir} 0755 pocketid pocketid -"
    ];

    # PocketID systemd service using nixpkgs package
    systemd.services.pocketid = {
        description = "PocketID Service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        
        serviceConfig = {
            Type = "simple";
            User = "pocketid";
            Group = "pocketid";
            WorkingDirectory = pocketidDataDir;
            EnvironmentFile = config.sops.templates."pocketid-env".path;
            ExecStart = "${pocketidPackage}/bin/pocket-id";
            Restart = "always";
            RestartSec = "10";
            
            # Security hardening
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ pocketidDataDir ];
            PrivateTmp = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
        };
        
        environment = {
            NODE_ENV = "production";
        };
    };
}