{ config, pkgs, ... }:

{
  services.rathole = {
    enable = true;
    package = pkgs.rathole;
    role = "server";
    
    settings = {
      server = {
        bind_addr = "0.0.0.0:4664";
        services = {
          immich = {
            token = "your-secure-token-here";
            bind_addr = "127.0.0.1:8080";
          };
          # Future services
          # nextcloud = {
          #   token = "another-secure-token";
          #   bind_addr = "127.0.0.1:8081";
          # };
        };
      };
    };
    
    # Use credentialsFile for sensitive tokens
    credentialsFile = "/var/lib/secrets/rathole/server-secrets.toml";
  };

  # Open firewall for rathole
  networking.firewall.allowedTCPPorts = [ 2333 80 443 ];
}