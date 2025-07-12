{ config, pkgs, ... }:
{
    sops = {
        secrets = {
            "MAXMIND_LICENSE_KEY".sopsFile = ../../../secrets/pocketid.yaml;
        };
        templates = {
            "pocketid-env".content = ''
                MAXMIND_LICENSE_KEY=${config.sops.placeholder."MAXMIND_LICENSE_KEY"}
                PORT=1441
            '';
        };
    };

    services.pocket-id = {
        enable = true;
        package = pkgs.unstable.pocket-id;
        settings = {
            APP_URL = "http://pocketid.lab.harkunwar.com";
            TRUST_PROXY = true;
        };
        environmentFile = config.sops.templates."pocketid-env".path;
    };

    # Open firewall for the specified port
    networking.firewall.allowedTCPPorts = [ 1441 ];
}