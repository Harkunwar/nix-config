{ config, pkgs, ... }:
let 
  user = "govee2mqtt";
  group = "govee2mqtt";
  sopsFile = ../../../secrets/homeassistant.yaml;
in
{
  sops = {
    secrets = {
      "govee/email".sopsFile = sopsFile;
      "govee/pass".sopsFile = sopsFile;
      "govee/api".sopsFile = sopsFile;
    };
    templates = {
      "govee2mqtt.env" = {
        mode = "0400";
        owner = user;
        group = group;
        content = ''
          GOVEE_EMAIL=${config.sops.placeholder."govee/email"}
          GOVEE_PASSWORD=${config.sops.placeholder."govee/pass"}
          GOVEE_API_KEY=${config.sops.placeholder."govee/api"}
          GOVEE_MQTT_HOST=localhost
        '';
      };
    };
  };

  services.govee2mqtt = {
    enable = true;
    user = user;
    group = group;
    environmentFile = config.sops.templates."govee2mqtt.env".path;
  };
}