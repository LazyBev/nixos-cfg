{
  pkgs,
  config,
  lib,
  ...
}:
let
  h = import ../../lib/helpers.nix { inherit lib; };
  nbfcCfg = config.services.nbfc;
  nbfcWrapperConfig = pkgs.writeText "nbfc.json" (
    builtins.toJSON {
      SelectedConfigId = nbfcCfg.modelName;
      EmbeddedControllerType = nbfcCfg.ecBackend;
      # Start in manual mode at a fixed speed so the daemon never auto-ramps.
      # 0 = off, -1 = auto. Values: [ CPU GPU CoolBoost ].
      TargetFanSpeeds = [ nbfcCfg.manualSpeed nbfcCfg.manualSpeed 0 ];
    }
  );
in
{
  options.services.nbfc = {
    enable = lib.mkEnableOption "NBFC fan control service";
    package = lib.mkPackageOption pkgs "nbfc-linux" { };
    modelName = h.mkStrOpt "" "Notebook model name";
    modelConfig = h.mkPathOpt "" "Path to the notebook model JSON config file";
    ecBackend = h.mkStrOpt "dev_port" "Embedded controller backend";
    manualSpeed = h.mkIntOpt 0 "Fixed manual fan speed (0-100) applied at boot";
  };

  config = lib.mkMerge [
    {
      services.nbfc = {
        enable = true;
        modelName = "Cyborg 15 A12UDX";
        modelConfig = ../../dotfiles/nbfc/cyborg-15-a12udx.json;
      };
    }
    (lib.mkIf nbfcCfg.enable {
      environment.systemPackages = [ nbfcCfg.package ];
      systemd.tmpfiles.rules = [
        "d /var/lib/nbfc 0755 root root -"
        "d /var/lib/nbfc/configs 0755 root root -"
        "L+ /var/lib/nbfc/configs/${nbfcCfg.modelName}.json - - - - ${nbfcCfg.modelConfig}"
      ];
      systemd.services.nbfc = {
        description = "NoteBook FanControl";
        after = [ "sysinit.target" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "systemd-tmpfiles-setup.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${nbfcCfg.package}/bin/nbfc_service -c ${nbfcWrapperConfig} -e ${nbfcCfg.ecBackend}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
      boot.kernelModules = [ "ec_sys" ];
    })
  ];
}
