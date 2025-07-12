{ inputs, config, pkgs, ... }:
{
    imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix"
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

    # Override the pocket-id package to use the unstable version
    nixpkgs.config.packageOverrides = pkgs: {
        pocket-id = pkgs.unstable.pocket-id;
    };

    services.pocket-id = {
        enable = true;
        settings = {
            PORT = 1441;
            TRUST_PROXY = true;
            APP_URL = "http://pocketid.lab.harkunwar.com";
        };
        environmentFile = config.sops.templates."pocketid-env".path;
    };
}