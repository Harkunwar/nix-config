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
    enable = true;
    package = pkgs.rathole;
    role = "server";
    credentialsFile = "${config.sops.templates."rathole-server.toml".path}";
    
    settings = {
      server = {
        bind_addr = "0.0.0.0:4664";
        services = {
          immich = {
            bind_addr = "127.0.0.1:8080";
          };
        };
      };
    };
    
    # Use credentialsFile for sensitive tokens
    credentialsFile = "/var/lib/secrets/rathole/server-secrets.toml";
  };

  # Open firewall for rathole
  networking.firewall.allowedTCPPorts = [ 2333 80 443 ];
}