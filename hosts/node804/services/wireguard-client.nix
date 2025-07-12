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
            allowedIPs = [ "10.100.0.0/24" ];
            # allowedIPs = [ "0.0.0.0/0" ];

            endpoint = "lab.harkunwar.com:61899";

            # Keep connection alive
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # Set DNS to use the same as other clients
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Open ports 80 and 443 for Caddy
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
}