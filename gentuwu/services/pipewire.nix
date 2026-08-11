{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."90-nosuspend" = {
      "context.properties"."suspend-node-idle-timeout" = -1;
    };
    wireplumber.extraConfig."90-norestore" = {
      "wireplumber.settings"."node.stream.restore-target" = false;
    };
  };
}
