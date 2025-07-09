{ config, pkgs, ... }:

{
  services.rathole = {
    enable = true;
    package = pkgs.rathole;
    role = "client";
    
    settings = {
      client = {
        remote_addr = "your-racknerd-ip:2333";
        services = {
          immich = {
            token = "your-secure-token-here";
            local_addr = "127.0.0.1:2283";
          };
          # Future services
          # nextcloud = {
          #   token = "another-secure-token";
          #   local_addr = "127.0.0.1:80";
          # };
        };
      };
    };
    
    # Use credentialsFile for sensitive tokens
    credentialsFile = "/var/lib/secrets/rathole/client-secrets.toml";
  };
}