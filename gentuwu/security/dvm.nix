{ config, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # dvm: disposable app launcher (Qubes-style "DisposableVM", firejail edition).
  #
  #     dvm <command> [args...]   run <command> with a thrown-away HOME inside
  #                               the browsernet sandbox (no LAN at all)
  #     dvm-browser               one-off librewolf with a zeroed profile —
  #                               no cookies, no history, nothing persists
  #
  # It is NOT a full VM: it shares your kernel. Use it for "I just want to
  # open this without it touching my machine", and the libvirtd VMs for real
  # untrusted binaries. The container qube (virtualisation/quarantine.nix) is
  # the middle ground for files.
  # ---------------------------------------------------------------------------
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "dvm" ''
      #!/bin/sh
      set -eu
      cmd="''${1:?usage: dvm <command> [args...]}"
      shift
      exec firejail \
        --name="dvm-$(date +%s)-$$" \
        --hostname="dvm-$UID" \
        --private \
        --netns=browsernet \
        --dns=10.254.0.1 \
        -- "$cmd" "$@"
    '')
    (pkgs.writeShellScriptBin "dvm-browser" ''
      #!/bin/sh
      # use the raw librewolf binary (not the firejail-wrapped one) so we don't
      # double-wrap; the profile comes fresh from --private every time
      exec dvm ${config.programs.firefox.finalPackage}/bin/librewolf --no-remote "$@"
    '')
  ];
}
