{
  services.home-assistant = {
    # opt-out from declarative configuration management
    config = null;
    lovelaceConfig = null;
    # configure the path to your config directory
    configDir = "/etc/home-assistant";
    # specify list of components required by your configuration
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
    ];
  };
}