{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hardware.opentabletdriver = {
    enable = lib.mkEnableOption "OpenTabletDriver udev rules and session daemon";
    blacklistedKernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "hid-uclogic"
        "wacom"
      ];
    };
    package = lib.mkPackageOption pkgs "opentabletdriver" { };
  };
  config = lib.mkIf config.hardware.opentabletdriver.enable {
    hardware.uinput.enable = true;
    environment.systemPackages = [ config.hardware.opentabletdriver.package ];
    services.udev.packages = [ config.hardware.opentabletdriver.package ];
    programs.modprobe.blacklist = config.hardware.opentabletdriver.blacklistedKernelModules;

    services.sessiond-hooks.hooks.opentabletdriver.settings = {
      on_start = lib.getExe' config.hardware.opentabletdriver.package "otd-daemon";
      restart = {
        on = "Failure";
        delay = 3;
      };
    };
  };
}
