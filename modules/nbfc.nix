{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nbfc;

  nbfc-config = pkgs.writeText "nbfc.json" (
    builtins.toJSON {
      SelectedConfigId = cfg.modelName;
      EmbeddedControllerType = cfg.ecBackend;
      TargetFanSpeeds = [
        cfg.manualSpeed
        cfg.manualSpeed
        0
      ];
    }
  );

  fan-control = pkgs.writeShellScriptBin "fan-control" ''
    state="$HOME/.local/state/fanspeed"
    notify() { notify-send -t 2500 "Fan control" "$1" 2>/dev/null; }
    clamp() { if [ "$1" -lt 0 ]; then echo 0; elif [ "$1" -gt 100 ]; then echo 100; else echo "$1"; fi; }
    cur=0
    [ -f "$state" ] && cur="$(cat "$state")"

    set_speed() {
      nbfc set -s "$1" && { echo "$1" > "$state"; notify "Fans: $1%"; }
    }

    case "$1" in
      auto)  nbfc set -a && notify "Fans: auto (profile)" ;;
      boost) set_speed 100 ;;
      up)    set_speed "$(clamp "$((cur + 20))")" ;;
      down)  set_speed "$(clamp "$((cur - 20))")" ;;
      *)     echo "usage: fan-control <auto|boost|up|down>" >&2; exit 1 ;;
    esac
  '';

  alias = name: arg: pkgs.writeShellScriptBin name "exec fan-control ${arg}";
in
{
  options.services.nbfc = {
    enable = lib.mkEnableOption "NBFC fan control service";
    package = lib.mkPackageOption pkgs "nbfc-linux" { };
    modelName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Notebook model name";
    };
    ecBackend = lib.mkOption {
      type = lib.types.str;
      default = "dev_port";
      description = "Embedded controller backend";
    };
    manualSpeed = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Fixed fan speed (0-100) applied at boot";
    };
  };

  config = lib.mkMerge [
    {
      services.nbfc = {
        enable = true;
        modelName = "Cyborg 15 A12UDX";
      };
    }

    (lib.mkIf cfg.enable {
      boot.kernelModules = [ "ec_sys" ];

      environment.systemPackages = [
        cfg.package
        fan-control
        (alias "fanauto" "auto")
        (alias "fanboost" "boost")
        (alias "fanup" "up")
        (alias "fandown" "down")
      ];

      finit.tmpfiles.rules = [ "d /var/lib/nbfc 0755 root root -" ];

      finit.services.nbfc = {
        description = "NoteBook FanControl";
        conditions = [ ];
        runlevels = "S";
        path = [
          cfg.package
          pkgs.coreutils
        ];
        command = "${cfg.package}/bin/nbfc_service -c ${nbfc-config} -e ${cfg.ecBackend}";
        respawn = true;
      };

      # Apply the fixed speed once the service is up.
      finit.tasks.fan-default = {
        description = "Apply fixed manual fan speed";
        runlevels = "2345";
        conditions = [ "service/nbfc/ready" ];
        path = [
          pkgs.bash
          pkgs.coreutils
          cfg.package
        ];
        command = pkgs.writeShellScript "fan-default" ''
          for _ in $(seq 30); do
            [ -S /run/nbfc_service.socket ] && break
            sleep 1
          done
          [ -S /run/nbfc_service.socket ] || exit 1
          nbfc set -s ${toString cfg.manualSpeed}
        '';
      };
    })
  ];
}
