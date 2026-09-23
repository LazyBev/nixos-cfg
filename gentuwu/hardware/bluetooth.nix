{
  hardware.bluetooth = {
    enable = true;
    # Radio stays DOWN until a device is actually needed: a powered BT radio
    # broadcasts discoverable beacons (chip MAC, class, name) that pair Wi-Fi
    # + BT MACs together for tracking. Toggle from the applet when needed.
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
}
