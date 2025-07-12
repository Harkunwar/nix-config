{ config, pkgs, inputs, ... }:
{
    imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix"
    ];

    disabledModules = [
        "services/security/pocket-id.nix"
    ];

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
        package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.pocket-id;
        settings = {
            APP_URL = "http://pocketid.lab.harkunwar.com";
            TRUST_PROXY = true;
            PORT = 1441;
        };
        environmentFile = config.sops.templates."pocketid-env".path;
    };

}