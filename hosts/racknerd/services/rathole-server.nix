{ config, pkgs, ... }:

{
  sops = {
    secrets = {
      "tokens/immich".sopsFile = ../../../secrets/rathole.yaml;
      "tokens/vaultwarden".sopsFile = ../../../secrets/rathole.yaml;
    };
    templates = {
      "rathole-server.toml".content = ''
        [server]
        bind_addr = "0.0.0.0:2333"

        [server.services.immich]
        token = "${config.sops.placeholder."tokens/immich"}"
        bind_addr = "127.0.0.1:6765"

        [server.services.vaultwarden]
        token = "${config.sops.placeholder."tokens/vaultwarden"}"
        bind_addr = "127.0.0.1:8222"
      '';
    };
  };

  services.rathole = {
    enable = true;
    role = "server";
    credentialsFile = "${config.sops.templates."rathole-server.toml".path}";
  };

  # Open firewall for rathole
  networking.firewall.allowedTCPPorts = [ 2333 80 443 ];
}