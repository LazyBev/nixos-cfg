{ config, lib, pkgs, ... }:
let
  h = import ../lib/helpers.nix { inherit lib; };
  hasTransparentProxy = config.services.tor.enable
    && (config.services.tor.settings.TransPort or []) != [];
in {
  # firejail
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      librewolf = {
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = pkgs.writeText "librewolf.profile" ''
          noblacklist /usr/share/pixmaps
          noblacklist /home/yari/.config/librewolf
          noblacklist /home/yari/.cache/librewolf
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
    };
  };
  # doas
  security.doas.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.doas.extraRules = lib.mkForce [{
    groups = [ "wheel" ];
    noPass = true;
    keepEnv = true;
  }];

  # apparmor
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = false;
  };

  # polkit
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) return polkit.Result.YES;
    });
  '';

  # usb lockdown: block new USB devices by default, manage whitelist via usbguard
  services.usbguard = {
    enable = true;
    rules = ''
      # Allow root hubs (always needed for USB to function)
      allow id 1d6b:0002  # USB 2.0 root hub
      allow id 1d6b:0003  # USB 3.0 root hub
      allow id 1d6b:0005  # USB Emulated root hub
      # Allow your specific devices
      allow id 30c9:0042  # Integrated Camera
      allow id 8087:0026  # Intel Bluetooth
    '';
    implicitPolicyTarget = "block";
    IPCAllowedUsers = [ "root" "yari" ];
    IPCAllowedGroups = [ "wheel" ];
  };

  # tor-hardening
  systemd.services.tor-hardening = lib.mkIf hasTransparentProxy {
    description = "Tor transparent proxy: redirect all TCP through Tor, DNS leak prevention";
    after = [ "tor.service" "network.target" ];
    wants = [ "tor.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iptables conntrack-tools ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      TOR_UID=$(id -u tor)

      # --- NAT: redirect TCP to TransPort ---
      iptables -t nat -N TOR_PROXY 2>/dev/null || iptables -t nat -F TOR_PROXY
      iptables -t nat -A TOR_PROXY -m owner --uid-owner "$TOR_UID" -j RETURN
      iptables -t nat -A TOR_PROXY -o lo -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9040 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9050 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9051 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp -j REDIRECT --to-ports 9040
      iptables -t nat -A OUTPUT -j TOR_PROXY

      # --- NAT: redirect DNS to DNSPort ---
      iptables -t nat -N TOR_DNS 2>/dev/null || iptables -t nat -F TOR_DNS
      iptables -t nat -A TOR_DNS -m owner --uid-owner "$TOR_UID" -j RETURN
      iptables -t nat -A TOR_DNS -o lo -j RETURN
      iptables -t nat -A TOR_DNS -p udp --dport 5353 -j RETURN
      iptables -t nat -A TOR_DNS -p udp --dport 53 -j REDIRECT --to-ports 5353
      iptables -t nat -A OUTPUT -j TOR_DNS

      # --- Filter: killswitch ---
      iptables -N TOR_OUT 2>/dev/null || iptables -F TOR_OUT
      iptables -A TOR_OUT -m owner --uid-owner "$TOR_UID" -j ACCEPT
      iptables -A TOR_OUT -o lo -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9040 -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9050 -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9051 -j ACCEPT
      iptables -A TOR_OUT -p udp --dport 5353 -j ACCEPT
      iptables -A TOR_OUT -p udp --dport 123 -j ACCEPT
      iptables -A TOR_OUT -m state --state ESTABLISHED,RELATED -j ACCEPT
      iptables -A TOR_OUT -j DROP
      iptables -A OUTPUT -j TOR_OUT

      # --- IPv6: drop everything to prevent leaks ---
      ip6tables -P OUTPUT DROP 2>/dev/null || true
    '';
    preStop = ''
      iptables -t nat -D OUTPUT -j TOR_PROXY 2>/dev/null || true
      iptables -t nat -F TOR_PROXY 2>/dev/null || true
      iptables -t nat -X TOR_PROXY 2>/dev/null || true
      iptables -t nat -D OUTPUT -j TOR_DNS 2>/dev/null || true
      iptables -t nat -F TOR_DNS 2>/dev/null || true
      iptables -t nat -X TOR_DNS 2>/dev/null || true
      iptables -D OUTPUT -j TOR_OUT 2>/dev/null || true
      iptables -F TOR_OUT 2>/dev/null || true
      iptables -X TOR_OUT 2>/dev/null || true
      ip6tables -P OUTPUT ACCEPT 2>/dev/null || true
      conntrack -F 2>/dev/null || true
    '';
  };

  # ── Network hardening ─────────────────────────────────
  networking.firewall.allowPing = false;
  networking.firewall.checkReversePath = "loose";

  # ── IPv6: block all output to prevent leaks ──────────
  systemd.services.ipv6-block = {
    description = "Block IPv6 output traffic";
    after = [ "firewall.service" ];
    requires = [ "firewall.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = [ pkgs.nftables ];
    preStart = ''
      nft add table inet ipv6block 2>/dev/null || true
      nft flush table inet ipv6block 2>/dev/null || true
      nft add chain inet ipv6block output '{ type filter hook output priority -5; policy accept; }'
      nft add rule inet ipv6block output oifname "lo" accept
      nft add rule inet ipv6block output meta nfproto ipv6 drop
    '';
    preStop = ''
      nft delete table inet ipv6block 2>/dev/null || true
    '';
  };

  # ── SSH hardening ─────────────────────────────────────
  services.openssh.settings.X11Forwarding = false;
  services.openssh.settings.AllowAgentForwarding = false;
  services.openssh.settings.MaxAuthTries = 3;

  # ── Kernel hardening ──────────────────────────────────
  security.lockKernelModules = true;

  # ── Privacy: disable discovery services ───────────────
  services.geoclue2.enable = false;
  services.avahi.enable = false;
}
