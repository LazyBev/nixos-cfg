{ config, lib, pkgs, ... }:
let
  cfg = config.services.nbfc;
  wrapperConfig = pkgs.writeText "nbfc.json" (builtins.toJSON {
    SelectedConfigId = cfg.modelName;
    EmbeddedControllerType = cfg.ecBackend;
  });
in {
  options.services.nbfc = {
    enable = lib.mkEnableOption "NBFC fan control service";
    package = lib.mkPackageOption pkgs "nbfc-linux" { };
    modelName = lib.mkOption {
      type = lib.types.str;
      description = "Notebook model name (selects config from configs directory)";
    };
    modelConfig = lib.mkOption {
      type = lib.types.path;
      description = "Path to the notebook model JSON config file";
    };
    ecBackend = lib.mkOption {
      type = lib.types.str;
      default = "dev_port";
      description = "EC backend (dev_port, acpi_ec, ec_sys)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d /var/lib/nbfc 0755 root root -"
      "d /var/lib/nbfc/configs 0755 root root -"
      "L+ /var/lib/nbfc/configs/${cfg.modelName}.json - - - - ${cfg.modelConfig}"
    ];

    systemd.services.nbfc = {
      description = "NoteBook FanControl";
      after = [ "sysinit.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "systemd-tmpfiles-setup.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${cfg.package}/bin/nbfc_service \
            -c ${wrapperConfig} \
            -e ${cfg.ecBackend}
        '';
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    boot.kernelModules = [ "ec_sys" ];
  };
}
