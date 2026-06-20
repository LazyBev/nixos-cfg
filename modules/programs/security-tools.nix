{ config, pkgs, lib, ... }: let
  cfg = builtins.elem config.vars.hostname [ "secbox" "secbox-laptop" ];
in lib.mkIf cfg {
  environment.systemPackages = with pkgs; [

    # === NETWORK SCANNING & ANALYSIS ===
    nmap
    masscan
    tcpdump
    wireshark
    arp-scan
    netcat-gnu
    dnsutils
    whois
    traceroute
    mtr
    iperf3
    macchanger

    # === WEB APP TESTING ===
    sqlmap
    nikto
    gobuster
    ffuf
    wfuzz
    dirb
    whatweb
    hydra
    wpscan

    # === EXPLOITATION ===
    metasploit
    exploitdb
    hydra
    john
    hashcat
    pwntools
    evil-winrm
    chisel
    ligolo-ng
    nbtscanner

    # === WIRELESS ===
    aircrack-ng
    kismet
    hostapd
    mdk4
    wavemon

    # === FORENSICS ===
    binwalk
    foremost
    sleuthkit
    volatility3
    testdisk
    ddrescue
    yara
    lsof

    # === REVERSE ENGINEERING ===
    ghidra-bin
    radare2
    cutter
    gdb
    strace
    ltrace
    binutils
    nasm

    # === SNIFFING / MITM ===
    bettercap
    mitmproxy
    ettercap
    ngrep
    tshark
    dsniff

    # === OSINT ===
    theharvester
    recon-ng
    sherlock
    holehe
    maigret

    # === PASSWORD / CRYPTO ===
    hashcat
    john
    hashid
    crunch
    pdfcrack

    # === ANONYMIZATION & TUNNELING ===
    tor
    torsocks
    nyx
    proxychains
    socat
    stunnel
    wireguard-tools
    openvpn
    ike-scan

    # === VULNERABILITY ANALYSIS ===
    nuclei
    legba
    lynis
    osquery

    # === REPORTING ===
    cherrytree

    # === GENERAL UTILITIES ===
    openssl
    curl
    jq
    yq
    python3
    perl
    ruby
    killall
    pciutils
    usbutils
    htop
    fastfetch
  ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;
  services.clamav.updater.enable = true;

  security.apparmor.enable = true;
}
