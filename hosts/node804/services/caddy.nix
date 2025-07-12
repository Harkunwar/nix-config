{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "immich.lab.harkunwar.com" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:4664
          
          # Optional: Add headers for better proxying
          header_up Host {upstream_hostport}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        '';
      };
      
      # Template for future services
      # "nextcloud.lab.harkunwar.com" = {
      #   extraConfig = ''
      #     reverse_proxy 127.0.0.1:8081
      #   '';
      # };
    };
  };

  # Enable automatic HTTPS with Let's Encrypt
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "your-email@example.com";
  # };
}