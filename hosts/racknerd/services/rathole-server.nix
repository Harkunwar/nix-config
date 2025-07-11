{ config, pkgs, ... }:

{
  sops = {
    secrets = {
      "tokens/immich".sopsFile = ../../../secrets/rathole.yaml;
      "tokens/vaultwarden".sopsFile = ../../../secrets/rathole.yaml;
    };
    templates = {
      "rathole-server.toml".content = ''
        [server.services.immich]
        token = "${config.sops.placeholder."tokens/immich"}";
      '';
    };
  };

  services.rathole = {
    enable = false;
    package = pkgs.rathole;
    role = "server";
    credentialsFile = "${config.sops.templates."rathole-server.toml".path}";
    
    settings = {
      server = {
        bind_addr = "0.0.0.0:2333";
        services = {
          immich = {
            bind_addr = "0.0.0.0:4664";
          };
        };
      };
    };
  };

  # Open firewall for rathole
  networking.firewall.allowedTCPPorts = [ 2333 80 443 ];
}