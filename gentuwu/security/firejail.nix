{ pkgs, config, ... }: {
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      # librewolf is the fully sandboxed browser. It joins the pre-built
      # `browsernet` netVM domain (networking/netvms.nix — a veth with NAT to
      # the internet), which keeps it isolated from the host net and LAN at the
      # cost of:
      #   - DNS resolves on 10.254.0.1 where AdGuardHome listens on the veth,
      #     so it still gets the adguard filtering/DoH chain (no more plaintext
      #     1.1.1.1 leak). ublock is force-installed via policies on top.
      #   - localhost web UIs (AdGuardHome :8080, qBittorrent) are unreachable
      #     from this profile — open those in qutebrowser.
      #   - inbound to the sandbox is impossible (NAT, no DNAT), so the old
      #     `netfilter` line is gone; the host firewall covers the rest.
      # Other apps wanting isolation pick any netvm domain: `netns <name>` +
      # `dns 10.254.<idx>.1`.
      librewolf = {
        executable = "${config.programs.firefox.finalPackage}/bin/librewolf";
        profile = pkgs.writeText "librewolf.profile" ''
          noblacklist /usr/share/pixmaps
          noblacklist /home/yari/.config/librewolf
          noblacklist /home/yari/.cache/librewolf
          noblacklist /home/yari/.local/share/pipewire
          noblacklist /dev/snd
          noblacklist /run/user
          netns browsernet
          dns 10.254.0.1
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };

      # Default browser. No `net` namespace on purpose: qutebrowser carries
      # no content ad-blocker, so it keeps the adguard DNS chain, and it's
      # the browser used for localhost web UIs (AdGuardHome, qBittorrent).
      # Runtime hardening only.
      qutebrowser = {
        executable = "${pkgs.qutebrowser}/bin/qutebrowser";
        profile = pkgs.writeText "qutebrowser.profile" ''
          noblacklist /home/yari/.config/qutebrowser
          noblacklist /home/yari/.cache/qutebrowser
          noblacklist /home/yari/.local/share/pipewire
          noblacklist /dev/snd
          noblacklist /run/user
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          netfilter
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };

      # PDFs are an untrusted attack surface and need no network: kill it.
      zathura = {
        executable = "${pkgs.zathura}/bin/zathura";
        profile = pkgs.writeText "zathura.profile" ''
          noblacklist /home/yari/.config/zathura
          noblacklist /home/yari/.cache/zathura
          net none
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };

      # Media playback (files and streams). Runtime hardening; network kept
      # (streaming). DNS left to the host chain.
      mpv = {
        executable = "${pkgs.mpv}/bin/mpv";
        profile = pkgs.writeText "mpv.profile" ''
          noblacklist /home/yari/.config/mpv
          noblacklist /home/yari/.cache/mpv
          noblacklist /home/yari/.local/share/mpv
          noblacklist /home/yari/.local/share/pipewire
          noblacklist /dev/snd
          noblacklist /run/user
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };

      proton-vpn = {
        executable = "${pkgs.proton-vpn}/bin/proton-vpn";
        profile = pkgs.writeText "protonvpn.profile" ''
          noblacklist /home/yari/.config/Proton
          noblacklist /home/yari/.local/share/Proton
          ipc.namespace
          machine-id
          netfilter
          private-tmp
          private-dev
          seccomp
          caps.drop all
        '';
      };

      # Email is the #1 human attack surface (phishing + attachment parsing).
      # Network kept for mail; otherwise hardened like the rest.
      thunderbird = {
        executable = "${pkgs.thunderbird}/bin/thunderbird";
        profile = pkgs.writeText "thunderbird.profile" ''
          noblacklist /home/yari/.thunderbird
          noblacklist /home/yari/.config/thunderbird
          noblacklist /home/yari/.cache/thunderbird
          noblacklist /home/yari/.local/share/pipewire
          noblacklist /dev/snd
          noblacklist /run/user
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          netfilter
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };

      # Dev tools execute arbitrary code from repos + extensions; wrap them.
      # Network kept (registries, language servers, remoting); inbound blocked.
      vscodium = {
        executable = "${pkgs.vscodium}/bin/vscodium";
        profile = pkgs.writeText "vscodium.profile" ''
          noblacklist /home/yari/.config/VSCodium
          noblacklist /home/yari/.cache/VSCodium
          noblacklist /home/yari/.vscode
          noblacklist /home/yari/.local/share/pipewire
          noblacklist /dev/snd
          noblacklist /run/user
          ipc.namespace
          machine-id
          hostname guest-fj-$UID
          netfilter
          nodvd
          private-tmp
          private-dev
          seccomp
          caps.drop all
          tracemode
        '';
      };
    };
  };
}
