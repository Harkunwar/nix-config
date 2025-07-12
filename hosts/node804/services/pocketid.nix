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
        settings = {
            TRUST_PROXY = true;
            PUBLIC_APP_URL = "http://pocketid.lab.harkunwar.com";
            PORT = 80;
            CADDY_DISABLED=true;
        };
        # environmentFile = "${config.sops.templates."pocketid-env".path}";
    };
}