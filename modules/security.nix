{ pkgs, ... }:
let
  firejail = "${pkgs.firejail}/bin/firejail";

  jailed =
    name: pkg:
    pkgs.writeShellScriptBin name ''
      exec ${firejail} --profile=/etc/firejail/${name}.profile ${pkg}/bin/${name} "$@"
    '';
in
{
  boot.kernel.sysctl = {
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.perf_event_paranoid" = 3;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    "vm.mmap_min_addr" = 65536;
    "vm.unprivileged_userfaultfd" = 0;
  };

  programs.doas.keepEnv = true;

  services.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) return polkit.Result.YES;
    });
  '';

  # Lock on lid close and after 20 min idle.
  services.elogind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "lock";
    IdleAction = "lock";
    IdleActionSec = "20min";
  };

  # ── Sandboxing ─────────────────────────────────────────
  environment.etc = {
    "firejail/generic.local".text = "include /etc/firejail/default.profile\n";
    "firejail/firejail.local".text = "";
    "firejail/librewolf.profile".text = "include /etc/firejail/default.profile\n";
    "firejail/mpv.profile".text = "include /etc/firejail/default.profile\n";
    "firejail/zathura.profile".text = "net none\n";
  };

  environment.systemPackages = [
    pkgs.firejail
    pkgs.clamav
    pkgs.usbguard
    (jailed "librewolf" pkgs.librewolf)
    (jailed "mpv" pkgs.mpv)
    (jailed "zathura" pkgs.zathura)

    # dvm <cmd>: run a command in a throwaway sandbox inside the browsernet netns.
    (pkgs.writeShellScriptBin "dvm" ''
      set -eu
      cmd="''${1:?usage: dvm <command> [args...]}"
      shift
      exec ${firejail} \
        --name="dvm-$(date +%s)-$$" \
        --hostname="dvm-$UID" \
        --private \
        --netns=browsernet \
        --dns=10.254.0.1 \
        -- "$cmd" "$@"
    '')
    (pkgs.writeShellScriptBin "dvm-browser" ''
      exec dvm ${pkgs.librewolf}/bin/librewolf --no-remote "$@"
    '')
  ];
}
