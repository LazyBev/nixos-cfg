{
  pkgs,
  systemd,
  lib,
  ...
}:
let
  share = "/var/lib/quarantine";
in
{
  # ---------------------------------------------------------------------------
  # quarantine: a headless Qubes-style isolation qube for UNTRUSTED FILES,
  # built on a NixOS container (systemd-nspawn).
  #
  # The container has:
  #   - its own network namespace, NO NAT, NO default route → no internet,
  #     no LAN, not even the eyebrows around. The only other end of its veth
  #     is you, the host, over 10.233.0.0/16.
  #   - an ephemeral rootfs (every start is a clean slate)
  #   - /work, writable, bound to host /var/lib/quarantine → that is the ONLY
  #     channel in/out, used by the `quarantine` helper below.
  #   - a small offline toolkit: unar, exiftool, file, bsdtar, ffmpeg,
  #     pdftotext, strings/objdump, hexdump.
  #
  # Usage:
  #     quarantine file.pdf other.zip ...   copies files into /work, prints
  #                                         exiftool/file/strings/pdftotext
  #                                         results to the host, one block each
  #     quarantine-shell                    interactive root shell inside
  # ---------------------------------------------------------------------------

  containers.quarantine = {
    autoStart = false;
    privateNetwork = true;
    hostAddress = "10.233.0.1";
    localAddress = "10.233.0.2/16";
    ephemeral = true;

    bindMounts.${share} = {
      mountPoint = "/work";
      isReadOnly = false;
    };

    config = {
      environment.systemPackages = with pkgs; [
        unar
        exiftool
        file
        unzip
        libarchive
        ffmpeg
        poppler-utils
        binutils
        hexdump
        (pkgs.writeShellScriptBin "quarantine-analyze" ''
          #!/bin/sh
          # run inside the container on one file, print everything interesting
          f="''${1:?quarantine-analyze <file>}"
          echo "══ $f ══"
          file "$f"
          exiftool "$f" 2>/dev/null || true
          case "$f" in
            *.pdf|*.PDF) pdftotext -layout "$f" - ;;
            *.zip) unzip -l "$f" ;;
            *.rar|*.7z|*.tar|*.tar.gz|*.tgz|*.tar.xz|*.tar.zst|*.gz|*.xz)
              unar -l "$f" 2>/dev/null || bsdtar -tvf "$f" ;;
            *.docx|*.docm|*.xlsx|*.pptx|*.pptm)
              echo "-- embedded parts:"; unzip -l "$f" | head -50 ;;
            *.exe|*.dll|*.bin|*.elf|*.so|*.o|*.iso|*.img)
              echo "-- strings:"; strings -n 8 -a "$f" | head -200 ;;
            *)
              echo "-- first 100 lines:"; head -c 4096 "$f" | strings -n 4 ;;
          esac
        '')
      ];
      services.getty.autologinUser = "root";
    };
  };

  systemd.tmpfiles.rules = [ "d ${share} 0755 root root -" ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "quarantine" ''
      #!/bin/sh
      # quarantine <file> [more...]
      set -e
      : "''${1:?usage: quarantine <file> [more files...]}"
      systemctl start container@quarantine.service
      for f in "$@"; do
        [ -e "$f" ] || { echo "skipping (not found): $f"; continue; }
        cp -- "$f" "${share}/$(basename -- "$f")"
      done
      machinectl shell quarantine /bin/sh -lc '
        for f in /work/*; do
          [ -f "$f" ] && quarantine-analyze "$f"
        done
      '
    '')
    (pkgs.writeShellScriptBin "quarantine-shell" ''
      #!/bin/sh
      systemctl start container@quarantine.service
      exec machinectl shell quarantine
    '')
  ];
}
