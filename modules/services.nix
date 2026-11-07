{ config, pkgs, ... }:
let
  uid = toString config.users.users.yari.uid;

  hook = on_start: on: delay: {
    settings = {
      inherit on_start;
      restart = { inherit on delay; };
    };
  };
in
{
  services = {
    sysklogd.enable = true;
    dbus.enable = true;
    keventd.enable = true;
    polkit.enable = true;

    openssh.settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
    dropbear.extraArgs = [
      "-p 22"
      "-K 300"
      "-s"
      "-w"
    ];
    flatpak.extraGroups = [ "wheel" ];

    sessiond-hooks.hooks = {
      pipewire = hook "${pkgs.pipewire}/bin/pipewire" "Always" 2;
      pipewire-pulse = hook "${pkgs.pipewire}/bin/pipewire-pulse" "Always" 2;
      wireplumber = hook "${pkgs.wireplumber}/bin/wireplumber" "Always" 2;
      mpd = hook "${pkgs.mpd}/bin/mpd --no-daemon /etc/mpd/mpd.conf" "Failure" 2;
    };
  };

  # ── MPD ────────────────────────────────────────────────
  environment.etc."mpd/mpd.conf".text = ''
    music_directory "/home/yari/Music"
    db_file "/home/yari/.mpd/database"
    log_file "/home/yari/.mpd/mpd.log"
    pid_file "/home/yari/.mpd/pid"
    state_file "/home/yari/.mpd/state"
    audio_output {
      type "pulse"
      name "PulseAudio (via PipeWire)"
      server "/run/user/${uid}/pulse/native"
    }
  '';

  finit.tmpfiles.rules = [
    "d /home/yari/Music 0755 yari users -"
    "d /home/yari/.mpd 0755 yari users -"
    "d /home/yari/.mpd/playlists 0755 yari users -"
  ];

  # ── AdGuard Home ───────────────────────────────────────
  finit.services.adguardhome = {
    description = "AdGuard Home DNS filter";
    conditions = [ "net/lo/up" ];
    command = "${pkgs.adguardhome}/bin/AdGuardHome -c /var/lib/AdGuardHome/AdGuardHome.yaml -w /var/lib/AdGuardHome";
    respawn = true;
    log = true;
  };

  environment.systemPackages = with pkgs; [
    adguardhome
    cloudflare-warp
    searxng
    mpd
    mpc
    pipewire
    wireplumber
    pavucontrol
  ];
}
