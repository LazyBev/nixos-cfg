{
  pkgs,
  lib,
  ...
}:
let
  # nixpkgs' `nym` attr tracks 2024.14, whose client predates the current
  # mainnet auth protocol (gateways reject it: "the legacy authentication
  # method is no longer supported"). Package the official release binary
  # instead; autoPatchelfHook fixes the ELF interpreter for NixOS.
  nym-socks5-client-bin = pkgs.stdenv.mkDerivation {
    pname = "nym-socks5-client-bin";
    version = "2026.15-bydgoszcz";

    src = pkgs.fetchurl {
      url = "https://github.com/nymtech/nym/releases/download/nym-binaries-v2026.15-bydgoszcz/nym-socks5-client";
      sha256 = "sha256-uxnKeFqDkK2LN75iFEf9zR3jGbb6q60TOp74xppYuLQ=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      install -m755 $src $out/bin/nym-socks5-client
    '';

    meta = {
      description = "Nym socks5 client (official release binary)";
      license = lib.licenses.asl20;
      mainProgram = "nym-socks5-client";
    };
  };
in
{
  # topaz (the privacy CLI) dependencies. System-level tools topaz shells
  # out to but that are not part of the pentester or tor stacks.
  environment.systemPackages = with pkgs; [
    whois
    yara
    osv-scanner
    wireguard-tools
    dnsmasq
    nym-socks5-client-bin # nym mixnet subsystem (modern client)
  ];
}
