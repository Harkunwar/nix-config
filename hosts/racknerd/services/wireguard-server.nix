/*
  WireGuard VPN Server Configuration for RackNerd

  This configuration sets up a WireGuard VPN server on a RackNerd VPS.

  How to add a new client:
  1. Generate a new key pair for the client:
      PrivateKey=$(wg genkey)
      PublicKey=$(echo $PrivateKey | wg pubkey)
  2. Add the public key to the `peers` section in this file.
  3. Add the sops secret in secrets/wireguard.yaml:
      wireguard:
        wg0:
          clients:
            <client-name>:
              private: <private-key>

  4. Create a new sops template for the client configuration in this file.
  5. qrencode the client configuration file locate at:
      qrencode -t ansiutf8 < /run/secrets/rendered/wireguard-<client-name>.conf
*/
{ config, pkgs, ... }:

let
  wg0ServerPublicKey = "/GmQTUpinK8gpnqJqI51CpNjErXdyszO8UnkDSiUzyg=";
  node804PublicKey = "xWfuwTk4sqarAFE/MG/Zw5aoJr2CCvZbroMfyu6plWY=";
  iphone12ProPublicKey = "+379Fqfb7hvrAxv9FAKVPHBmVzRppWmCxPaa6FMzYFw=";
  macbookPro14PublicKey = "C9iwII6H0BpSXIkJmrnE0twOvcxThoOLn2qSU6BVxkY=";
in
{
  sops.secrets = {
    "wireguard/wg0/server/private" = {
      owner = "systemd-network";
      group = "systemd-network";
      mode = "0400";
      sopsFile = ../../../secrets/wireguard.yaml;
    };
    "wireguard/wg0/clients/iphone12pro/private" = {
      mode = "0444";
      sopsFile = ../../../secrets/wireguard.yaml;
    };
    "wireguard/wg0/clients/macbookpro14/private" = {
      mode = "0444";
      sopsFile = ../../../secrets/wireguard.yaml;
    };
    "ip" = {
      sopsFile = ../../../secrets/wireguard.yaml;
    };
  };

  # Sops template for iPhone client configuration
  sops.templates."wireguard-iphone12pro.conf" = {
    content = ''
      [Interface]
      PrivateKey = ${config.sops.placeholder."wireguard/wg0/clients/iphone12pro/private"}
      Address = 10.100.0.2/32
      DNS = 8.8.8.8, 1.1.1.1

      [Peer]
      PublicKey = ${wg0ServerPublicKey}
      AllowedIPs = 0.0.0.0/0
      Endpoint = ${config.sops.placeholder."ip"}:61899
      PersistentKeepalive = 25
    '';
    owner = "harkunwar";
    group = "users";
    mode = "0644";
  };

  # Sops template for Macbook Pro 14 client configuration
  sops.templates."wireguard-macbookpro14.conf" = {
    content = ''
      [Interface]
      PrivateKey = ${config.sops.placeholder."wireguard/wg0/clients/macbookpro14/private"}
      Address = 10.100.0.3/32
      DNS = 8.8.8.8, 1.1.1.1

      [Peer]
      PublicKey = ${wg0ServerPublicKey}
      AllowedIPs = 0.0.0.0/0
      Endpoint = ${config.sops.placeholder."ip"}:61899
      PersistentKeepalive = 25
    '';
    owner = "harkunwar";
    group = "users";
    mode = "0644";
  };


  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" ];

      extraCommands = ''
        # SNAT rules
        iptables -t nat -A POSTROUTING -d 10.100.0.101 -p tcp --dport 80 -j MASQUERADE
        iptables -t nat -A POSTROUTING -d 10.100.0.101 -p tcp --dport 443 -j MASQUERADE
      '';

      extraStopCommands = ''
        # Clean up SNAT rules
        iptables -t nat -D POSTROUTING -d 10.100.0.101 -p tcp --dport 80 -j MASQUERADE 2>/dev/null || true
        iptables -t nat -D POSTROUTING -d 10.100.0.101 -p tcp --dport 443 -j MASQUERADE 2>/dev/null || true
      '';

      forwardPorts = [
        {
          destination = "10.100.0.101:80";
          proto = "tcp";
          sourcePort = 80;
        }
        {
          destination = "10.100.0.101:443";
          proto = "tcp";
          sourcePort = 443;
        }
        {
          destination = "10.100.0.101:4664";
          proto = "tcp";
          sourcePort = 4664;
        }
      ];
    };
  };

  # WireGuard VPN Configuration
  networking.wireguard.interfaces = {
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens on. Must be accessible by the client.
      listenPort = 61899;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      peers = [
        {
          publicKey = node804PublicKey;
          allowedIPs = [ "10.100.0.101/32" ];
        }
        {
          publicKey = iphone12ProPublicKey;
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          publicKey = macbookPro14PublicKey;
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];

      # Add missing postSetup
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
      '';

      # Path to the private key file managed by sops
      privateKeyFile = config.sops.secrets."wireguard/wg0/server/private".path;
    };
  };

  # Enable IP forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 61899 ];
    allowedTCPPorts = [ 80 443 ];
  };

}







