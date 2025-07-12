{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;

    ackage = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@35fb8474f57d7476329f75d63eebafb95a93022f" ];
      hash = "sha256-F/jqR4iEsklJFycTjSaW8B/V3iTGqqGOzwYBUXxRKrc=";
    };

    virtualHosts = {
      # "immich.lab.harkunwar.com" = {
      #   extraConfig = ''
      #     # Disable automatic HTTPS for lab domain
      #     auto_https off
          
      #     reverse_proxy 127.0.0.1:4664 {
      #       header_up Host {upstream_hostport}
      #       header_up X-Real-IP {remote_host}
      #       header_up X-Forwarded-For {remote_host}
      #       header_up X-Forwarded-Proto {scheme}
      #     }
      #   '';
      # };
      
      # Alternative: Use HTTP explicitly
      "http://immich.lab.harkunwar.com" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:4664 {
            header_up Host {upstream_hostport}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
          }
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

  # Open firewall ports
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

  # Enable automatic HTTPS with Let's Encrypt
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "your-email@example.com";
  # };
}