{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ocl-icd
    audit
    obfs4
    nftables
    dropbear
    macchanger
    aria2
    raylib
    zls
  ];
  systemd.tmpfiles.rules = [
    "L+ /usr/sbin/nft - - - - ${pkgs.nftables}/bin/nft"
  ];
}
