{ config, pkgs, ... }:

let
  wg0ServerPublicKey = "/GmQTUpinK8gpnqJqI51CpNjErXdyszO8UnkDSiUzyg=";
in
{
  sops.secrets = {
    "wireguard/wg0/clients/node804/private" = {
      owner = "systemd-network";
      group = "systemd-network";
      mode = "0400";
      sopsFile = ../../../secrets/wireguard.yaml;
    };
  };

  # WireGuard Client Configuration
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        # IP address assigned to this client (using /32 like other clients)
        ips = [ "10.100.0.101/32" ];

        # Path to the private key file managed by sops
        privateKeyFile = config.sops.secrets."wireguard/wg0/clients/node804/private".path;

        peers = [
          {
            # RackNerd server public key
            publicKey = wg0ServerPublicKey;

            # Route all traffic through VPN (like iPhone/MacBook)
            # allowedIPs = [ "10.100.0.0/24" ];
            allowedIPs = [ "0.0.0.0/0" ];

            endpoint = "104.168.82.76:61899";

            # Keep connection alive
            persistentKeepalive = 25;
          }
        ];
            # Prevent this interface from becoming the default route
        postSetup = ''
          # Remove the default route that might be added
          ${pkgs.iproute2}/bin/ip route del default dev wg0 2>/dev/null || true
          
          # Add specific routes for traffic you want to go through the VPN
          ${pkgs.iproute2}/bin/ip route add 10.100.0.0/24 dev wg0
        '';
      };
    };
  };

  # Set DNS to use the same as other clients
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Open ports 80 and 443 for Caddy
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 4664 ];
  };
}