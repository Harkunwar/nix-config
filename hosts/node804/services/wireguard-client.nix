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
    "ip" = {
      sopsFile = ../../../secrets/wireguard.yaml;
    };
  };

  # Sops template for node804 client configuration
  sops.templates."wireguard-node804.conf" = {
    content = ''
      [Interface]
      PrivateKey = ${config.sops.placeholder."wireguard/wg0/clients/node804/private"}
      Address = 10.100.0.101/24

      [Peer]
      PublicKey = ${wg0ServerPublicKey}
      AllowedIPs = 10.100.0.0/24
      Endpoint = ${config.sops.placeholder."ip"}:61899
      PersistentKeepalive = 25
    '';
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # WireGuard Client Configuration using config file
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        configFile = config.sops.templates."wireguard-node804.conf".path;
      };
    };
  };
}
