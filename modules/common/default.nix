{ inputs, ... }: {
  flake.nixosModules.common = { config, lib, ... }: {
    options.gentuwu.hostType = lib.mkOption {
      type = lib.types.enum [ "desktop" "laptop" ];
      default = "desktop";
      description = "Whether this machine is a desktop or laptop";
    };

    imports = [
      ../core/boot
      ../core/programs
      ../core/services
      ../home/apps
      ../home/services
      ../home/environment.nix
      ../home/fonts.nix
      ../home/security.nix
      ../hosts/gentuwu/disk-desktop.nix
      ../hosts/gentuwu/nvidia-desktop.nix
      ../hosts/gentuwu-laptop/disk-laptop.nix
      ../hosts/gentuwu-laptop/nvidia-laptop.nix
    ];

    config = {
      gentuwu.desktopHardware.enable = lib.mkDefault (config.gentuwu.hostType == "desktop");
      gentuwu.nvidia.enable = lib.mkDefault (config.gentuwu.hostType == "desktop");
      gentuwu.laptopHardware.enable = lib.mkDefault (config.gentuwu.hostType == "laptop");
      gentuwu.nvidiaLaptop.enable = lib.mkDefault (config.gentuwu.hostType == "laptop");
    };
  };
}
