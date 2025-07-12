{ config, pkgs, pkgs-unstable, ... }:
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
        package = pkgs-unstable.pocket-id;
        settings = {
            PUBLIC_APP_URL = "http://192.168.2.101";
            APP_URL = "http://192.168.2.101";
        };
        environmentFile = "${config.sops.templates."pocketid-env".path}";
    };
}