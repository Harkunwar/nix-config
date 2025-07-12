{ config, pkgs, ... }:

{
  sops = {
    secrets = {
      "tokens/node804-http".sopsFile = ../../../secrets/rathole.yaml;
      "tokens/node804-https".sopsFile = ../../../secrets/rathole.yaml;
    };
  };

  templates = {
    "rathole-client.toml".content = ''
      [client]
      remote_addr = "lab.harkunwar.com:2333"

      [client.services.node804-http]
      token = "${config.sops.placeholder."tokens/node804-http"}"
      local_addr = "127.0.0.1:80"

      [client.services.node804-https]
      token = "${config.sops.placeholder."tokens/node804-https"}"
      local_addr = "127.0.0.1:443"
    '';
  };

  services.rathole = {
    enable = true;
    package = pkgs.rathole;
    role = "client";
    
    credentialsFile = "${config.sops.templates."rathole-client.toml".path}";
  };
}