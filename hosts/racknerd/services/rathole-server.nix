{ config, pkgs, ... }:

{
  sops = {
    secrets = {
      "tokens/node804-http".sopsFile = ../../../secrets/rathole.yaml;
      "tokens/node804-https".sopsFile = ../../../secrets/rathole.yaml;
    };
    templates = {
      "rathole-server.toml".content = ''
        [server]
        bind_addr = "0.0.0.0:2333"

        [server.services.node804-http]
        token = "${config.sops.placeholder."tokens/node804-http"}"
        bind_addr = "0.0.0.0:80"

        [server.services.node804-https]
        token = "${config.sops.placeholder."tokens/node804-https"}"
        bind_addr = "0.0.0.0:4664"
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