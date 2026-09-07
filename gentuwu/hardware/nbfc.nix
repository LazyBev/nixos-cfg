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
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "fan-control" ''
          # fan-control <auto|boost|up|down> — authoritative fan commands
          # Manual speed is persisted in ~/.local/state/fanspeed so fanup/fandown
          # operate relative to the last applied manual speed.
          state="$HOME/.local/state/fanspeed"
          notify() { notify-send -t 2500 "Fan control" "$1" 2>/dev/null; }
          cur=0
          [ -f "$state" ] && cur="$(cat "$state")"
          clamp() { if [ "$1" -lt 0 ]; then echo 0; elif [ "$1" -gt 100 ]; then echo 100; else echo "$1"; fi; }
          case "$1" in
            auto)    nbfc set -a && notify "Fan control: auto (profile)" ;;
            boost)   nbfc set -s 100 && { echo 100 > "$state"; notify "Fan boost: 100%"; } ;;
            up)      next=$(clamp "$((cur + 20))"); nbfc set -s "$next" && { echo "$next" > "$state"; notify "Fans increased to $next%"; } ;;
            down)    next=$(clamp "$((cur - 20))"); nbfc set -s "$next" && { echo "$next" > "$state"; notify "Fans decreased to $next%"; } ;;
            *)       echo "usage: fan-control <auto|boost|up|down>" >&2; exit 1 ;;
          esac
        '')
        (pkgs.writeShellScriptBin "fanauto" "exec fan-control auto")
        (pkgs.writeShellScriptBin "fanboost" "exec fan-control boost")
        (pkgs.writeShellScriptBin "fanup" "exec fan-control up")
        (pkgs.writeShellScriptBin "fandown" "exec fan-control down")
        nbfcCfg.package
      ];
      systemd.tmpfiles.rules = [
        "d /var/lib/nbfc 0755 root root -"
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
