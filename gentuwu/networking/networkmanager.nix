{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;

  # ─── wifi-harden: retrofit saved NM profiles ────────────────────────────────
  # The module-level wifi.macAddress only sets the default for *new* profiles.
  # This walks every saved connection and pins:
  #   wifi  : cloned-mac-address = stable-ssid (per-SSID stable random MAC)
  #           + 802-11-wireless-security.pmf = 2 (optional 802.11w PMF) or,
  #           with `wifi-harden strict`, 3 = require PMF and refuse to join
  #           networks without it.
  #   ether : cloned-mac-address = random
  # Idempotent, so running it on every boot only touches profiles that are out
  # of spec (a profile active at the moment of change gets one re-association
  # as its MAC rolls over; that's the one-time migration cost).
  wifiHarden = pkgs.writeShellScriptBin "wifi-harden" ''
    #!/bin/sh
    set -u
    mode="''${1:-}"
    for conn in $(nmcli -g UUID,TYPE connection show | sed -n 's/^\([^:]*\):802-11-wireless$/\1/p'); do
      [ "$(nmcli -g wifi.cloned-mac-address connection show "$conn")" = stable-ssid ] || \
        nmcli connection modify "$conn" wifi.cloned-mac-address stable-ssid
      case "$mode" in
        strict) nmcli connection modify "$conn" 802-11-wireless-security.pmf 3 ;;
        *)
          if nmcli -g 802-11-wireless-security.key-mgmt connection show "$conn" | grep -q .; then
            nmcli connection modify "$conn" 802-11-wireless-security.pmf 2
          fi
          ;;
      esac
    done
    for conn in $(nmcli -g UUID,TYPE connection show | sed -n 's/^\([^:]*\):802-3-ethernet$/\1/p'); do
      [ "$(nmcli -g ethernet.cloned-mac-address connection show "$conn")" = random ] || \
        nmcli connection modify "$conn" ethernet.cloned-mac-address random
    done
  '';
in
{
  boot.kernelModules = [
    "dummy"
    "wireguard"
    "nft_fib_ipv4"
    "nft_fib_ipv6"
    "nft_ct"
  ];
  networking = {
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      dns = mkForce "none";
      wifi = {
        # stable-ssid: one stable random MAC per SSID (per-SSID identity across
        # reconnects, distinct MAC per different network). `random` (new MAC
        # every connect) is stronger but breaks portals/DHCP reservations and
        # makes association look like a fresh guest each time. Scans already
        # randomize (scanRandMacAddress defaults true), so probe requests don't
        # leak your identity while unconnected.
        powersave = false;
        backend = "iwd";
        macAddress = "stable-ssid";
      };
      ethernet.macAddress = "random";
      # nvmh-* are the host ends of the netVM domain veths, router endpoints
      # (see networking/netvms.nix) — never real links. The quarantine
      # container's ve-*/vb-* are already unmanaged via its own udev rule.
      unmanaged = [ "interface-name:nvmh-*" ];
    };
    wireless.iwd = {
      enable = true;
      settings = {
        Settings.AutoConnect = true;
        Network.EnableIPv6 = false;
      };
    };
    nameservers = [
      "127.0.0.1"
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  environment.systemPackages = [ wifiHarden ];

  systemd.services.wifi-harden = {
    description = "Apply stable-ssid MAC + 802.11w PMF to saved NetworkManager profiles";
    after = [ "networkmanager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${wifiHarden}/bin/wifi-harden
    '';
  };
}
