{ config, pkgs, ... }:
{
  sops = {
    secrets = {
      "EDIT_ALL_ZONE_API_KEY".sopsFile = ../../../secrets/cloudflare.yaml;
    };
    templates = {
      "cloudflare-caddy-env".content = ''
        CLOUDFLARE_EDIT_ALL_ZONE_API_KEY=${config.sops.placeholder."EDIT_ALL_ZONE_API_KEY"}
      '';
    };
  };

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2-0.20250506153119-35fb8474f57d" ];
      hash = "sha256-xMxNAg08LDVifhsryGXV22LXqgRDdfjmsU0NfbUJgMg=";
    };

    # Global configuration for Cloudflare DNS challenge
    globalConfig = ''
        acme_dns cloudflare {env.CLOUDFLARE_EDIT_ALL_ZONE_API_KEY}
    '';

    virtualHosts = {
      # HTTPS with Cloudflare DNS challenge
      "immich.lab.harkunwar.com" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_EDIT_ALL_ZONE_API_KEY}
          }
          
          reverse_proxy 127.0.0.1:4664 {
            header_up Host {upstream_hostport}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
          }
        '';
      };

      # Pocket ID service
      "pocketid.lab.harkunwar.com" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_EDIT_ALL_ZONE_API_KEY}
          }
          
          reverse_proxy 127.0.0.1:1411
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

  # Environment variables for Cloudflare API
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    "${config.sops.templates."cloudflare-caddy-env".path}"
  ];

  # Open firewall ports
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

  # Enable automatic HTTPS with Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "10580591+Harkunwar@users.noreply.github.com";
  };
}