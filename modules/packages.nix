{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # base
    vim
    helix
    git
    wget
    iproute2
    foot
    fish
    atuin
    nh
    nixos-rebuild-ng

    # session
    steam
    steam-run
    appimage-run

    # network / opsec
    nftables
    dropbear
    obfs4
    macchanger
    aria2
    whois
    yara
    osv-scanner
    wireguard-tools
    dnsmasq
    audit

    # graphics / wine
    ocl-icd
    vulkan-loader
    vulkan-tools
    wineWow64Packages.stable
    winetricks

    # dev
    raylib
    zls
  ];

  finit.tmpfiles.rules = [ "L+ /usr/sbin/nft - - - - ${pkgs.nftables}/bin/nft" ];
}
