{ ... }:
{
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = true;
      permit_join = true;
      mqtt = {
        # MQTT base topic for zigbee2mqtt MQTT messages
        base_topic = "zigbee2mqtt";
        # MQTT server URL
        server = "mqtt://127.0.0.1:1883";
        # MQTT server authentication, uncomment if required:
        # user = "zigbee";
        # password = lib.fileContents <secrets/zigbee/password>;
      };

      serial = {
        port = "/dev/ttyACM0";
      };
      frontend = {
        enabled = true;
        port = 8293;
        host = "0.0.0.0";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8293 ];
}
