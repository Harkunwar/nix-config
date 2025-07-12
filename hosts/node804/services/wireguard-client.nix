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
        # IP address assigned to this client
        ips = [ "10.100.0.101/24" ];

        # Path to the private key file managed by sops
        privateKeyFile = config.sops.secrets."wireguard/wg0/clients/node804/private".path;

        peers = [
          {
            # RackNerd server public key
            publicKey = wg0ServerPublicKey;

            # Route all traffic through VPN for full connectivity
            allowedIPs = [ "10.100.0.0/24" ];

            # Server endpoint - replace with actual RackNerd server IP
            # You'll need to replace this with your actual server IP
            endpoint = "lab.harkunwar.com:61899";

            # Keep connection alive
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}