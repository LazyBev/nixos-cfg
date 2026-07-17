{ config, pkgs, lib, ... }: let
  cfg = builtins.elem config.vars.hostname [ "secbox" "secbox-laptop" ];
in lib.mkIf cfg {
  environment.systemPackages = with pkgs; [
    nmap masscan tcpdump wireshark arp-scan netcat-gnu dnsutils
    whois traceroute mtr iperf3 macchanger
    sqlmap nikto gobuster ffuf wfuzz dirb whatweb hydra wpscan
    metasploit exploitdb john hashcat pwntools evil-winrm chisel ligolo-ng nbtscanner
    aircrack-ng kismet hostapd mdk4 wavemon
    binwalk foremost sleuthkit volatility3 testdisk ddrescue yara lsof
    ghidra-bin radare2 cutter gdb strace ltrace binutils nasm
    bettercap mitmproxy ettercap ngrep tshark dsniff
    theharvester recon-ng sherlock holehe maigret
    hashcat john hashid crunch pdfcrack
    tor torsocks nyx proxychains socat stunnel wireguard-tools openvpn ike-scan
    nuclei legba lynis osquery
    cherrytree
    openssl curl jq yq python3 perl ruby killall pciutils usbutils htop fastfetch
  ];
  services.openssh.enable = true;
  services.fail2ban.enable = true;
  services.clamav.updater.enable = true;
  security.apparmor.enable = true;
}
