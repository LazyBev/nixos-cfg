{ config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption mkIf mkMerge;
  cfg = config.gentuwu.powerProfiles;
in {
  options.gentuwu.powerProfiles.default = mkOption {
    type = types.nullOr (types.enum [ "performance" "balanced" "power-saver" ]);
    default = "balanced";
  };

  config = mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };
    }
    (mkIf (cfg.default != null) {
      powerManagement.enable = true;
      powerManagement.cpuFreqGovernor =
        if cfg.default == "performance" then "performance"
        else "powersave";
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
    })
  ];
}
