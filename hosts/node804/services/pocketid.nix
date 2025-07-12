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
        package = pkgs.unstable.pocket-id;
        settings = {
            APP_URL = "http://pocketid.lab.harkunwar.com";
            TRUST_PROXY = true;
            PORT=1441
        };
        environmentFile = config.sops.templates."pocketid-env".path;
    };

}