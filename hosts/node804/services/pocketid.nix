{ config, pkgs, ... }:
{
    sops = {
        secrets = {
            "MAXMIND_LICENSE_KEY".sopsFile = ../../../secrets/pocketid.yaml;
        };
        templates = {
            "pocketid-env".content = ''
                MAXMIND_LICENSE_KEY=${config.sops.placeholder."MAXMIND_LICENSE_KEY"}
            '';
        };
    };

    services.pocket-id = {
        enable = true;
        package = pkgs.pocket-id;
        settings = {
            TRUST_PROXY = true;
            PUBLIC_APP_URL = "http://pocketid.lab.harkunwar.com";
            PORT = 1411;
            # Database configuration - using SQLite for simplicity
            DATABASE_URL = "sqlite:///var/lib/pocket-id/pocket-id.db";
            # Allow setup mode for initial configuration
            SETUP_MODE = true;
        };
        # environmentFile = "${config.sops.templates."pocketid-env".path}";
    };

    # Ensure the data directory exists with proper permissions
    systemd.tmpfiles.rules = [
        "d /var/lib/pocket-id 0755 pocket-id pocket-id -"
    ];
}