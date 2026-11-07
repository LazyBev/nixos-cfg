{ pkgs, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    opentabletdriver.enable = true;
  };

  services = {
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = [ pkgs.blueman ];
}
