{ config, pkgs, ... }:
{
  sops.secrets = {
    "wireguard.wg0.server.private" = {
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0400";
        sopsFile = ../../../secrets/racknerd.yaml;
    };
    "wireguard.wg0.server.public" = {
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0444";
        sopsFile = ../../../secrets/racknerd.yaml;
    };
    "wireguard.wg0.clients.iphone12pro.private" = {
        mode = "0444";
        sopsFile = ../../../secrets/racknerd.yaml;
    };
    "wireguard.wg0.clients.iphone12pro.public" = {
        mode = "0444";
        sopsFile = ../../../secrets/racknerd.yaml;
    };
    "ip" = {
        sopsFile = ../../../secrets/racknerd.yaml;
    };
  };

  # Sops template for iPhone client configuration
  sops.templates."wireguard-iphone12pro.conf" = {
    content = ''
      [Interface]
      PrivateKey = ${config.sops.placeholder."wireguard.wg0.clients.iphone12pro.private"}
      Address = 10.100.0.2/32
      DNS = 8.8.8.8, 1.1.1.1

      [Peer]
      PublicKey = ${config.sops.placeholder."wireguard.wg0.server.public"}
      AllowedIPs = 0.0.0.0/0
      Endpoint = ${config.sops.placeholder."ip"}:61899
      PersistentKeepalive = 25
    '';
    owner = "harkunwar";
    group = "users";
    mode = "0644";
  };

  # WireGuard VPN Configuration
  networking.wireguard.interfaces = {
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens on. Must be accessible by the client.
      listenPort = 61899;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -A INPUT -p udp --dport 61899 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT

        # Post setup command to add clients
        ${pkgs.wireguard-tools}/bin/wg set wg0 peer $(cat ${config.sops.secrets."wireguard.wg0.clients.iphone12pro.public".path}) allowed-ips 10.100.0.2/32
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -D INPUT -p udp --dport 61899 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
      '';

      # Path to the private key file managed by sops
      privateKeyFile = config.sops.secrets."wireguard.wg0.server.private".path;
    };
  };

  # Enable IP forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # Open WireGuard port in firewall
  networking.firewall.allowedUDPPorts = [ 61899 ];

}







