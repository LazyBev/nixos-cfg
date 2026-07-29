# TOPAZ - Security & Privacy Tools
# This file is `source`d from fish.nix (interactiveShellInit)
# Color vars and helpers (_box, _check_tool, _check_doas) are in fish.nix

      set -g TOPAZ_VERSION '2.1.0'

      function topaz --description 'TOPAZ Suite - security & privacy tools'
        switch (count $argv)
          case 0
            _topaz_guide
          case '*'
            switch $argv[1]
              case status;      _topaz_status $argv[2..]
              case audit;       _topaz_audit $argv[2..]
              case tor;         _topaz_tor $argv[2..]
              case vpn;         _topaz_vpn $argv[2..]
              case warp;        _topaz_warp $argv[2..]
              case dns;         _topaz_dns $argv[2..]
              case firewall fw; _topaz_fw $argv[2..]
              case microphone mic; _topaz_mic $argv[2..]
              case webcam cam;  _topaz_cam $argv[2..]
              case mac-randomizer mac-randomiser mac; _topaz_mac $argv[2..]
              case sysinfo;     _topaz_sysinfo $argv[2..]
              case battery;     _topaz_battery $argv[2..]
              case weather;     _topaz_weather $argv[2..]
              case disk;        _topaz_disk $argv[2..]
              case processes procs; _topaz_procs $argv[2..]
              case cache;       _topaz_cache $argv[2..]
              case ports;       _topaz_ports $argv[2..]
              case mounts;      _topaz_mounts $argv[2..]
              case tailscale;   _topaz_tailscale $argv[2..]
              case what;        _topaz_what $argv[2..]
              case recent;      _topaz_recent $argv[2..]
              case clean;       _topaz_clean $argv[2..]
              case leaktest leak-test; _topaz_leaktest $argv[2..]
              case bluetooth bt; _topaz_bluetooth $argv[2..]
              case geoclue;     _topaz_geoclue $argv[2..]
              case timeline;    _topaz_timeline $argv[2..]
              case watch;       _topaz_watch $argv[2..]
              case guide help -h --help; _topaz_guide
              case -v --version version; _topaz_version
              case '*'
                echo "$_C_RED x$_C_RESET unknown command: $_C_BOLD$argv[1]$_C_RESET"
                echo "  run $_C_GREEN topaz guide$_C_RESET for available commands"
                return 1
            end
        end
      end

      function _topaz_version --description 'Show TOPAZ version'
        echo "topaz $TOPAZ_VERSION"
        echo "$_C_DIM  platform: $(uname -o) $(uname -m) fish $(fish --version | string replace 'fish, version ' '')$_C_RESET"
      end

      function _topaz_tor --description 'Tor routing'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz tor <on|off|status>"
          return 1
        end
        _check_doas; or return 1
        switch $argv[1]
          case -h --help; echo "usage: topaz tor <on|off|status>"; return 0
          case on
            rm -f /tmp/.topaz_ip_cache
            if test -f /etc/tor/torrc-obfs4
              doas pkill -x tor 2>/dev/null
              doas tor -f /etc/tor/torrc-obfs4 --RunAsDaemon 1
              echo "$_C_GREEN v$_C_RESET tor obfs4 started"
            else
              doas systemctl start tor
              echo "$_C_GREEN v$_C_RESET tor started"
            end
          case off
            rm -f /tmp/.topaz_ip_cache
            doas pkill -x tor 2>/dev/null
            doas systemctl stop tor 2>/dev/null
            echo "$_C_GREEN v$_C_RESET tor stopped"
          case status
            if pgrep -x tor >/dev/null 2>&1
              echo "$_C_GREEN active$_C_RESET  $_C_DIM(pid (pgrep -x tor))$_C_RESET"
              set -l routing (doas iptables -C OUTPUT -j TOR_OUT 2>&1)
              if test $status -eq 0
                echo "  routing: $_C_GREEN ON$_C_RESET"
              else
                echo "  routing: $_C_YELLOW daemon only$_C_RESET"
              end
            else
              echo "$_C_RED tor not running$_C_RESET"
            end
        end
      end

      function _topaz_vpn --description 'ProtonVPN management'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz vpn <on|off|status|openvpn>"
          return 1
        end
        switch $argv[1]
          case -h --help; echo "usage: topaz vpn <on|off|status|openvpn>"; return 0
          case on
            rm -f /tmp/.topaz_ip_cache
            if command -v protonvpn-app >/dev/null 2>&1
              doas systemctl start protonvpn-killswitch 2>/dev/null
              protonvpn-app &
              echo "$_C_GREEN v$_C_RESET killswitch + ProtonVPN GUI"
            else
              echo "$_C_YELLOW ?$_C_RESET install protonvpn or use warp/tor instead"
            end
          case off
            rm -f /tmp/.topaz_ip_cache
            pkill protonvpn-app 2>/dev/null
            doas systemctl stop protonvpn-killswitch 2>/dev/null
            doas iptables -D OUTPUT -j PROTON_KS 2>/dev/null; or true
            doas iptables -F PROTON_KS 2>/dev/null; or true
            doas iptables -X PROTON_KS 2>/dev/null; or true
            echo "$_C_GREEN v$_C_RESET protonvpn + killswitch stopped"
          case status
            if ip link show proton0 >/dev/null 2>&1
              echo "$_C_GREEN connected$_C_RESET  $_C_DIM(proton0)$_C_RESET"
            else
              echo "$_C_RED disconnected$_C_RESET"
            end
            if doas iptables -C OUTPUT -j PROTON_KS 2>/dev/null
              echo "  killswitch: $_C_GREEN ON$_C_RESET"
            else
              echo "  killswitch: $_C_YELLOW OFF$_C_RESET"
            end
          case openvpn
            _box "OpenVPN TCP/443"
            echo ""
            echo "$_C_YELLOW ?$_C_RESET ProtonVPN GUI -> Settings -> Connection -> OpenVPN (TCP) port 443"
            echo "$_C_DIM This wraps VPN in TLS, looks like HTTPS to basic DPI$_C_RESET"
        end
      end

      function _topaz_warp --description 'Cloudflare WARP'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz warp <on|off|status>"
          return 1
        end
        _check_tool warp-cli; or return 1
        switch $argv[1]
          case -h --help; echo "usage: topaz warp <on|off|status>"; return 0
          case on
            rm -f /tmp/.topaz_ip_cache
            warp-cli connect 2>&1
            and echo "$_C_GREEN v$_C_RESET WARP connected"
          case off
            rm -f /tmp/.topaz_ip_cache
            warp-cli disconnect 2>&1
            and echo "$_C_GREEN v$_C_RESET WARP disconnected"
          case status
            warp-cli status 2>&1
        end
      end

      function _topaz_dns --description 'DNS settings & leak test'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz dns <on|off|leak|status>"
          return 1
        end
        switch $argv[1]
          case -h --help; echo "usage: topaz dns <on|off|leak|status>"; return 0
          case on
            rm -f /tmp/.topaz_ip_cache
            doas resolvectl dnssec wlan0 yes
            echo "$_C_GREEN v$_C_RESET DNSSEC enabled"
          case off
            rm -f /tmp/.topaz_ip_cache
            doas resolvectl dnssec wlan0 no
            echo "$_C_GREEN v$_C_RESET DNSSEC disabled"
          case leak
            echo "$_C_CYAN o$_C_RESET testing DNS leak..."
            curl -s --max-time 5 https://ipleak.net/json/ | string match -r '"dns":"([^"]+)"' | head -1
            or echo "  $_C_DIM (timeout - no internet?)$_C_RESET"
          case status
            echo "  $_C_DIM server:$_C_RESET "(resolvectl status | string match -r 'Current DNS Server: .+' | string replace 'Current DNS Server: ' "")
            set -l d (resolvectl query dnssec-failed.org 2>&1)
            if test $status -ne 0
              echo "  DNSSEC: $_C_GREEN ON$_C_RESET"
            else
              echo "  DNSSEC: $_C_RED OFF$_C_RESET"
            end
        end
      end

      function _topaz_fw --description 'Firewall & killswitch'
        if test (count $argv) -eq 0
          echo "$_C_RED x$_C_RESET usage: topaz firewall <on|off|status|list>"
          return 1
        end
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz firewall <on|off|status|list>"; return 0; end
        _check_doas; or return 1
        switch $argv[1]
          case on
            if systemctl list-units --all protonvpn-killswitch.service 2>/dev/null | grep -q protonvpn-killswitch
              doas systemctl start protonvpn-killswitch
              echo "$_C_GREEN v$_C_RESET killswitch ON (ProtonVPN chain)"
            else
              doas iptables -P OUTPUT DROP
              doas iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
              doas iptables -A OUTPUT -o lo -j ACCEPT
              doas iptables -A OUTPUT -p udp --dport 2408 -j ACCEPT
              doas iptables -A OUTPUT -p udp --dport 51820 -j ACCEPT
              doas iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT
              echo "$_C_GREEN v$_C_RESET killswitch ON (DROP policy, allow EST/lo/WARP/WG/OVPN)"
            end
          case off
            if systemctl list-units --all protonvpn-killswitch.service 2>/dev/null | grep -q protonvpn-killswitch
              doas systemctl stop protonvpn-killswitch
            end
            doas iptables -D OUTPUT -j PROTON_KS 2>/dev/null; or true
            doas iptables -F PROTON_KS 2>/dev/null; or true
            doas iptables -X PROTON_KS 2>/dev/null; or true
            doas iptables -P OUTPUT ACCEPT
            doas iptables -F OUTPUT
            doas ip6tables -P OUTPUT ACCEPT 2>/dev/null; or true
            echo "$_C_GREEN v$_C_RESET killswitch OFF"
          case status
            if doas iptables -C OUTPUT -j PROTON_KS 2>/dev/null
              echo "  killswitch: $_C_GREEN ACTIVE (ProtonVPN)$_C_RESET"
            else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
              echo "  killswitch: $_C_GREEN ACTIVE (Tor)$_C_RESET"
            else if doas nft list chain ip filter OUTPUT 2>/dev/null | string match -q 'drop'
              echo "  firewall: $_C_GREEN nftables output rules$_C_RESET"
            else if ip link show CloudflareWARP >/dev/null 2>&1
              echo "  firewall: $_C_GREEN WARP daemon active$_C_RESET"
            else
              echo "  firewall: $_C_RED NO OUTPUT RULES$_C_RESET"
            end
            if ip6tables -L OUTPUT -n 2>/dev/null | string match -q DROP
              echo "  ipv6: $_C_GREEN blocked$_C_RESET"
            else
              echo "  ipv6: $_C_YELLOW allowed$_C_RESET"
            end
          case list
            echo "  $_C_CYAN iptables OUTPUT rules$_C_RESET"
            doas iptables -L OUTPUT -v -n --line-numbers 2>/dev/null | head -30
            echo ""
            echo "  $_C_CYAN nftables rules$_C_RESET"
            doas nft list ruleset 2>/dev/null | head -40
        end
      end

      function _topaz_mic --description 'Microphone privacy'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz mic <on|off|status>"
          return 1
        end
        _check_tool wpctl "PipeWire (wireplumber)"; or return 1
        switch $argv[1]
          case -h --help; echo "usage: topaz mic <on|off|status>"; return 0
          case off
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
            echo "$_C_GREEN v$_C_RESET microphone muted"
          case on
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
            echo "$_C_GREEN v$_C_RESET microphone unmuted"
          case status
            if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | string match -q MUTED
              echo "  mic: $_C_GREEN muted$_C_RESET"
            else
              echo "  mic: $_C_RED unmuted$_C_RESET"
            end
        end
      end

      function _topaz_cam --description 'Webcam privacy'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz cam <on|off|status>"
          return 1
        end
        _check_doas; or return 1
        switch $argv[1]
          case -h --help; echo "usage: topaz cam <on|off|status>"; return 0
          case off
            for dev in /dev/video*
              doas chmod 000 $dev 2>/dev/null
            end
            echo "$_C_GREEN v$_C_RESET webcam blocked (permissions removed)"
          case on
            for dev in /dev/video*
              doas chmod 660 $dev 2>/dev/null
            end
            echo "$_C_GREEN v$_C_RESET webcam unblocked"
          case status
            set -l blocked 0
            for dev in /dev/video*
              if test -e $dev
                set -l mode (string sub -s 4 -l 3 (stat -c %A $dev))
                if test "$mode" = "---"
                  set blocked (math $blocked + 1)
                end
              end
            end
            if test $blocked -gt 0
              echo "  webcam: $_C_GREEN blocked$_C_RESET ($blocked devices)"
            else
              echo "  webcam: $_C_YELLOW accessible$_C_RESET"
            end
        end
      end

      function _topaz_mac --description 'MAC address randomization'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz mac <on|off|status>"
          return 1
        end
        _check_tool nmcli "networkmanager"; or return 1
        switch $argv[1]
          case -h --help; echo "usage: topaz mac <on|off|status>"; return 0
          case on
            nmcli connection modify wlan0 802-11-wireless.cloned-mac-address random
            nmcli device reapply wlan0 2>/dev/null
            echo "$_C_GREEN v$_C_RESET MAC randomization enabled"
          case off
            nmcli connection modify wlan0 802-11-wireless.cloned-mac-address permanent
            nmcli device reapply wlan0 2>/dev/null
            echo "$_C_GREEN v$_C_RESET MAC randomization disabled"
          case status
            set -l mac (cat /sys/class/net/wlan0/address 2>/dev/null)
            set -l mode (nmcli -t -f cloned-mac-address connection show wlan0 2>/dev/null | string split ':' -f2 | string trim)
            if test "$mode" = random
              echo "  wlan0: $_C_GREEN randomized$_C_RESET $mac"
            else
              echo "  wlan0: $_C_YELLOW permanent$_C_RESET $mac"
            end
        end
      end

      function _topaz_sysinfo --description 'System info'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz sysinfo"; return 0; end
        set -l cores (nproc)
        set -l mem (free -h | string match -r '^Mem:\s+(\S+)' | head -1 | string replace -r 'Mem:\s+' "")
        set -l load (uptime | string match -r 'load average:.*$' | string replace 'load average: ' "")
        set -l kernel (uname -r)
        set -l host (hostname)
        set -l upt (uptime -p | string replace 'up ' "")
        _box "$host"
        echo "  $_C_DIM kernel:$_C_RESET  $kernel"
        echo "  $_C_DIM uptime:$_C_RESET  $upt"
        echo "  $_C_DIM cores:$_C_RESET   $cores"
        echo "  $_C_DIM memory:$_C_RESET  $mem"
        echo "  $_C_DIM load:$_C_RESET    $load"
      end

      function _topaz_battery --description 'Battery status'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz battery"; return 0; end
        if test -d /sys/class/power_supply/BAT0
          set -l cap (cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
          set -l status (cat /sys/class/power_supply/BAT0/status 2>/dev/null)
          echo "  $_C_DIM battery:$_C_RESET $cap% ($status)"
          if test "$cap" -le 20
            echo "  $_C_YELLOW ?$_C_RESET low battery"
          end
        else
          echo "  $_C_DIM battery:$_C_RESET no battery found"
        end
        echo "  $_C_DIM power:$_C_RESET  "(upower -i (upower -e | string match -r 'bat')) | string match -r 'energy-rate:' | string trim
      end

      function _topaz_weather --description 'Weather report'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz weather [city] [-f]"; return 0; end
        set -l city ""
        set -l units metric
        if test (count $argv) -ge 1
          if test $argv[1] = "-f" -o $argv[1] = "--fahrenheit"
            set units imperial
          else
            set city $argv[1]
          end
        end
        if test (count $argv) -ge 2
          if test $argv[2] = "-f" -o $argv[2] = "--fahrenheit"
            set units imperial
          end
        end
        set -l url "https://wttr.in/$city?$units&format=%C+%t+%w+%h"
        curl -s --max-time 5 "$url"
        or echo "$_C_RED x$_C_RESET weather unavailable"
      end

      function _topaz_disk --description 'Disk usage'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz disk"; return 0; end
        echo "  $_C_MAGENTA filesystems$_C_RESET"
        df -h | string match -r '^/' | while read -l line
          echo "  $line"
        end
        echo ""
        echo "  $_C_MAGENTA nix store$_C_RESET"
        du -sh /nix/store 2>/dev/null | string trim
        echo "  $_C_DIM (run 'topaz cache -f' to GC)$_C_RESET"
      end

      function _topaz_procs --description 'Process monitor'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz procs [N] [-t]"; return 0; end
        set -l count 15
        set -l tree 0
        for arg in $argv
          switch $arg
            case '-t' '--tree'
              set tree 1
            case '*'
              set count $arg
          end
        end
        if test $tree -eq 1
          ps auxf | head -n (math $count + 1)
        else
          ps aux --sort=-%mem | head -n (math $count + 1)
        end
      end

      function _topaz_cache --description 'Clear caches'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz cache [-f] [-n]"; return 0; end
        set -l full 0
        set -l dry 0
        for arg in $argv
          switch $arg
            case '-f' '--full'
              set full 1
            case '-n' '--dry-run'
              set dry 1
          end
        end
        echo "$_C_CYAN o$_C_RESET clearing user caches..."
        rm -rf ~/.cache/* 2>/dev/null
        if test $full -eq 1
          if test $dry -eq 1
            echo "$_C_CYAN o$_C_RESET dry run: would run nix GC..."
            doas nix-collect-garbage --delete-older-than 30d --dry-run 2>&1 | head -5
          else
            echo "$_C_CYAN o$_C_RESET nix garbage collection..."
            doas nix-collect-garbage -d 2>&1 | head -5
            doas nix-collect-garbage --delete-old 2>&1 | head -5
            nix store optimise 2>&1 | head -3
          end
        end
        echo "$_C_GREEN v$_C_RESET done"
      end

      function _topaz_ports --description 'Port listing, scanning, blocking'
        if test (count $argv) -ge 1
          if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz ports [list|scan|block|unblock] [...]"; return 0; end
          switch $argv[1]
            case list
              set -l filter ""; set -l proto ""
              for arg in $argv[2..]
                switch $arg
                  case -h --help; echo "usage: topaz ports list [port] [-p proto]"; return 0
                  case '-p' '--proto'
                  case '*'
                    if test -z "$proto"; set proto $arg; else; set filter $arg; end
                end
              end
              if test -n "$proto"; ss -tulnp | string match -r "$proto" | head -30
              else if test -n "$filter"; ss -tulnp | string match -r ":$filter " | head -30
              else; ss -tulnp | head -30; end
            case scan
              if test (count $argv) -lt 2
                echo "$_C_RED x$_C_RESET usage: topaz ports scan <target> [-t N] [-r R] [-u]"; return 1
              end
              if test "$argv[2]" = -h -o "$argv[2]" = --help 2>/dev/null; echo "usage: topaz ports scan <target> [-t N] [-r R] [-u]"; return 0; end
              set -l target $argv[2]; set -l threads 4; set -l range ""; set -l udp 0; set -l i 2
              while test $i -le (count $argv)
                switch $argv[$i]
                  case '-t' '--threads'; set i (math $i + 1); set threads $argv[$i]
                  case '-r' '--range'; set i (math $i + 1); set range $argv[$i]
                  case '-u' '--udp'; set udp 1
                end
                set i (math $i + 1)
              end
              set -l cmd "nmap -T4 -n"
              if test $udp -eq 1; set cmd "$cmd -sU"; else; set cmd "$cmd -sT"; end
              if test -n "$range"; set cmd "$cmd -p $range"; end
              if not command -qv nmap
                echo "$_C_YELLOW ?$_C_RESET nmap not installed, trying rustscan..."
                if command -qv rustscan; rustscan -a $target $range
                else; echo "$_C_RED x$_C_RESET install nmap for port scanning"; return 1; end
              else; eval $cmd $target; end
            case block
              if test "$argv[2]" = -h -o "$argv[2]" = --help 2>/dev/null; echo "usage: topaz ports block <port> [tcp|udp|both]"; return 0; end
              _check_doas; or return 1
              if test (count $argv) -lt 2
                echo "$_C_RED x$_C_RESET usage: topaz ports block <port> [tcp|udp|both]"; return 1
              end
              set -l port $argv[2]; set -l proto tcp
              if test (count $argv) -ge 3; set proto $argv[3]; end
              if test "$proto" = both
                doas iptables -A OUTPUT -p tcp --dport $port -j DROP
                doas iptables -A OUTPUT -p udp --dport $port -j DROP
                echo "$_C_GREEN v$_C_RESET blocked $port (tcp+udp)"
              else
                doas iptables -A OUTPUT -p $proto --dport $port -j DROP
                echo "$_C_GREEN v$_C_RESET blocked $port/$proto"
              end
            case unblock
              if test "$argv[2]" = -h -o "$argv[2]" = --help 2>/dev/null; echo "usage: topaz ports unblock <port> [tcp|udp|both]"; return 0; end
              _check_doas; or return 1
              if test (count $argv) -lt 2
                echo "$_C_RED x$_C_RESET usage: topaz ports unblock <port> [tcp|udp|both]"; return 1
              end
              set -l port $argv[2]; set -l proto tcp
              if test (count $argv) -ge 3; set proto $argv[3]; end
              if test "$proto" = both
                doas iptables -D OUTPUT -p tcp --dport $port -j DROP 2>/dev/null
                doas iptables -D OUTPUT -p udp --dport $port -j DROP 2>/dev/null
                echo "$_C_GREEN v$_C_RESET unblocked $port (tcp+udp)"
              else
                doas iptables -D OUTPUT -p $proto --dport $port -j DROP 2>/dev/null
                echo "$_C_GREEN v$_C_RESET unblocked $port/$proto"
              end
            case '*'
              echo "$_C_RED x$_C_RESET unknown: topaz ports <list|scan|block|unblock>"
              return 1
          end
        else
          ss -tulnp | head -30
        end
      end

      function _topaz_mounts --description 'Show mounted filesystems'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz mounts"; return 0; end
        mount | string match -r '^/' | while read -l line
          set -l parts (string split ' ' $line)
          echo "  $parts[1]  ->  $parts[3]"
        end
      end

      function _topaz_tailscale --description 'Tailscale status'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz tailscale"; return 0; end
        if command -qv tailscale
          tailscale status 2>&1 | head -20
        else
          echo "$_C_DIM tailscale not installed$_C_RESET"
        end
      end

      function _topaz_what --description 'Identify a command or file'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz what <command>"; return 0; end
        if test (count $argv) -eq 0
          echo "$_C_RED x$_C_RESET usage: topaz what <command>"
          return 1
        end
        set -l target $argv[1]
        echo "  $_C_DIM type:$_C_RESET   "(type -t $target 2>/dev/null; or file $target)
        echo "  $_C_DIM path:$_C_RESET   "(type -p $target 2>/dev/null; or readlink -f $target 2>/dev/null)
        if command -q $target
          echo "  $_C_DIM version:$_C_RESET "($target --version 2>&1 | head -1)
        end
      end

      function _topaz_recent --description 'Recent files'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz recent [files|cmds] [N]"; return 0; end
        set -l mode files
        set -l count 10
        if test (count $argv) -ge 1
          set mode $argv[1]
        end
        if test (count $argv) -ge 2
          set count $argv[2]
        end
        switch $mode
          case cmds
            history | head -n $count
          case files '*'
            find ~ -maxdepth 3 -type f -name '*.py' -o -name '*.rs' -o -name '*.nix' -o -name '*.md' 2>/dev/null \
              | xargs ls -lt 2>/dev/null | head -n $count
        end
      end

      function _topaz_clean --description 'Wipe privacy traces'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz clean"; return 0; end
        echo "$_C_CYAN o$_C_RESET wiping shell history..."
        history clear 2>/dev/null
        if test -f ~/.bash_history; cat /dev/null >~/.bash_history 2>/dev/null; end
        if test -f ~/.zsh_history; cat /dev/null >~/.zsh_history 2>/dev/null; end
        echo "$_C_CYAN o$_C_RESET clearing clipboard..."
        if command -qv wl-copy; wl-copy "" 2>/dev/null; end
        if command -qv xclip; xclip -i /dev/null 2>/dev/null; end
        echo "$_C_CYAN o$_C_RESET clearing recent file lists..."
        rm -f ~/.local/share/recently-used.xbel 2>/dev/null
        rm -rf ~/.local/share/RecentDocuments 2>/dev/null
        echo "$_C_CYAN o$_C_RESET trimming journal (older than 1d)..."
        doas journalctl --vacuum-time=1d 2>/dev/null; or echo "  $_C_DIM (needs doas)$_C_RESET"
        echo "$_C_CYAN o$_C_RESET clearing temp dirs..."
        rm -rf /tmp/* 2>/dev/null
        rm -rf ~/.cache/* 2>/dev/null
        echo "$_C_GREEN v$_C_RESET privacy traces wiped"
      end

      function _topaz_leaktest --description 'DNS & IP leak test'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz leaktest"; return 0; end
        echo "$_C_CYAN o$_C_RESET DNS test..."
        set -l resolvers (resolvectl dns 2>/dev/null | string replace -r '^\S+\s+' '' | string trim)
        if test -n "$resolvers"
          echo "  DNS servers: $resolvers"
          if string match -qr '127\.|192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.|0\.0\.0\.0' -- $resolvers
            echo "  status: $_C_GREEN local resolver$_C_RESET"
          else
            echo "  status: $_C_YELLOW external DNS servers (possible leak)$_C_RESET"
          end
        else
          echo "  $_C_DIM (no DNS info)$_C_RESET"
        end
        echo ""
        echo "$_C_CYAN o$_C_RESET public IP..."
        set -l ip (curl -s --max-time 5 https://ipinfo.io/json 2>/dev/null)
        if test -n "$ip"
          printf '%s\n' "$ip" | string match -r '"ip":"([^"]+)"' | head -1
          printf '%s\n' "$ip" | string match -r '"org":"([^"]+)"' | head -1
        else
          echo "  $_C_DIM (timeout)$_C_RESET"
        end
        echo ""
        echo "  $_C_DIM WebRTC leak: open about:webrtc in Firefox$_C_RESET"
        echo "  $_C_DIM or visit:  https://browserleaks.com/webrtc$_C_RESET"
      end

      function _topaz_bluetooth --description 'Toggle Bluetooth'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz bluetooth <on|off|status>"
          return 1
        end
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz bluetooth <on|off|status>"; return 0; end
        _check_tool bluetoothctl "bluez"; or return 1
        switch $argv[1]
          case on
            doas systemctl start bluetooth 2>/dev/null
            echo "power on" | bluetoothctl 2>/dev/null
            echo "$_C_GREEN v$_C_RESET Bluetooth ON"
          case off
            echo "power off" | bluetoothctl 2>/dev/null
            doas systemctl stop bluetooth 2>/dev/null
            echo "$_C_GREEN v$_C_RESET Bluetooth OFF"
          case status
            if systemctl is-active bluetooth >/dev/null 2>&1
              echo "  bluetooth: $_C_GREEN active$_C_RESET"
              bluetoothctl show 2>/dev/null | string match -r '^\s+(?:Name|Powered|Discoverable|Pairable):\s+\S+' | head -4
            else
              echo "  bluetooth: $_C_RED inactive$_C_RESET"
            end
        end
      end

      function _topaz_geoclue --description 'Toggle geolocation'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz geoclue <on|off|status>"
          return 1
        end
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz geoclue <on|off|status>"; return 0; end
        switch $argv[1]
          case on
            doas systemctl start geoclue 2>/dev/null
            echo "$_C_GREEN v$_C_RESET geolocation ON"
          case off
            doas systemctl stop geoclue 2>/dev/null
            echo "$_C_GREEN v$_C_RESET geolocation OFF"
          case status
            if systemctl is-active geoclue >/dev/null 2>&1
              echo "  geoclue: $_C_GREEN active$_C_RESET"
            else
              echo "  geoclue: $_C_RED inactive$_C_RESET"
            end
        end
      end

      function _topaz_timeline --description 'Recent state changes'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz timeline"; return 0; end
        echo "  $_C_CYAN recent state changes (journalctl)$_C_RESET"
        journalctl -o short-iso --no-pager -p info \
          --user-unit=warp-svc.service \
          -u tor.service \
          -u protonvpn-killswitch.service \
          -u bluetooth.service \
          -u geoclue.service \
          2>/dev/null | tail -15
        echo ""
        echo "  $_C_DIM (topaz commands are not logged - this shows service state changes)$_C_RESET"
      end

      function _topaz_watch --description 'Live per-process network traffic'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz watch [-t type]"; return 0; end
        set -l mode ss
        if test "$argv[1]" = -t -a (count $argv) -ge 2
          switch $argv[2]
            case ss;    set mode ss
            case nethogs; set mode nethogs
            case iftop; set mode iftop
          end
        end
        switch $mode
          case ss
            echo "$_C_CYAN o$_C_RESET current connections (refresh every 2s, Ctrl+C to stop)..."
            watch -n 2 "ss -tupwn | head -30"
          case nethogs
            _check_tool nethogs; or return 1
            doas nethogs
          case iftop
            _check_tool iftop; or return 1
            doas iftop
        end
      end

      function _topaz_guide --description 'List all TOPAZ commands'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz guide"; return 0; end
        _box "TOPAZ v$TOPAZ_VERSION"
        echo ""
        echo "  $_C_BOLD usage:$_C_RESET $_C_GREEN topaz <command> [options]$_C_RESET"
        echo "  $_C_BOLD help:$_C_RESET  $_C_GREEN topaz <command> --help$_C_RESET"
        echo ""
        echo "$_C_CYAN ── NETWORK ──────────────────────────────$_C_RESET"
        _tgd "tor on|off|status" "Tor routing with obfs4 bridges"
        _tgd "vpn on|off|status|openvpn" "ProtonVPN management"
        _tgd "warp on|off|status" "Cloudflare WARP (MASQUE/QUIC)"
        _tgd "dns on|off|leak|status" "DNSSEC & DNS leak test"
        echo ""
        echo "$_C_CYAN ── FIREWALL ─────────────────────────────$_C_RESET"
        _tgd "firewall on|off|status|list" "Killswitch & rules view"
        echo ""
        echo "$_C_CYAN ── PRIVACY ──────────────────────────────$_C_RESET"
        _tgd "microphone on|off|status" "Mic mute control"
        _tgd "webcam on|off|status" "Webcam permission block"
        _tgd "mac-randomizer on|off|status" "MAC address randomization"
        echo ""
        echo "$_C_CYAN ── ANALYSIS ─────────────────────────────$_C_RESET"
        _tgd "status" "Privacy & security dashboard"
        _tgd "audit" "Comprehensive security audit"
        echo ""
        echo "$_C_CYAN ── SYSTEM ───────────────────────────────$_C_RESET"
        _tgd "sysinfo" "System resources"
        _tgd "battery" "Battery status"
        _tgd "weather [city] [-f]" "Weather report"
        _tgd "disk" "Disk & nix store usage"
        _tgd "processes [N] [-t]" "Process monitor (N=count, -t=tree)"
        _tgd "cache [-f] [-n]" "Clear caches (-f: nix GC)"
        echo ""
        echo "$_C_CYAN ── NET TOOLS ────────────────────────────$_C_RESET"
        _tgd "ports [scan|block|unblock]" "Port listing, scanning, blocking"
        _tgd "tailscale" "Tailscale status"
        echo ""
        echo "$_C_CYAN ── FILES ────────────────────────────────$_C_RESET"
        _tgd "mounts" "Show mounted filesystems"
        _tgd "recent [files|cmds] [N]" "Recent files or commands"
        _tgd "what <target>" "Identify command/file"
        _tgd "clean" "Wipe privacy traces"
        echo ""
        echo "$_C_CYAN ── HARDWARE ──────────────────────────────$_C_RESET"
        _tgd "bluetooth on|off|status" "Toggle Bluetooth radio"
        _tgd "geoclue on|off|status" "Toggle geolocation service"
        echo ""
        echo "$_C_CYAN ── DIAGNOSTICS ───────────────────────────$_C_RESET"
        _tgd "leaktest" "DNS & IP leak test"
        _tgd "timeline" "Recent state changes (journal)"
        _tgd "watch" "Live per-process network traffic"
        echo ""
        echo "  $_C_DIM help:  topaz <command> --help$_C_RESET"
      end

      function _tgd --no-scope-shadowing --description 'Guide helper'
        set -l cmd $argv[1]
        set -l desc $argv[2..]
        printf "  $_C_GREEN o$_C_RESET $_C_BOLD%-30s$_C_RESET %s\n" "$cmd" "$desc"
      end

      # ─── STATUS ────────────────────────────────────────────

      function _topaz_status --description 'Privacy & security dashboard'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz status"; return 0; end
        _box "privacy status"
        echo ""
        echo "  $_C_CYAN tor$_C_RESET"
        if pgrep -x tor >/dev/null 2>&1
          set -l r (doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null; echo $status)
          echo "    o routing:  $(if test $r -eq 0; echo $_C_GREEN ON$_C_RESET; else; echo $_C_RED OFF$_C_RESET; end)"
          echo "    o daemon:   $_C_GREEN ON$_C_RESET"
        else
          echo "    o routing:  $_C_RED OFF$_C_RESET"
          echo "    o daemon:   $_C_RED OFF$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN vpn$_C_RESET"
        if ip link show proton0 >/dev/null 2>&1
          echo "    o status:    $_C_GREEN connected$_C_RESET"
        else
          echo "    o status:    $_C_RED Disconnected$_C_RESET"
        end
        set -l ks (doas iptables -C OUTPUT -j PROTON_KS 2>/dev/null; echo $status)
        echo "    o killswitch: $(if test $ks -eq 0; echo $_C_GREEN ON$_C_RESET; else; echo $_C_RED OFF$_C_RESET; end)"

        echo ""
        echo "  $_C_CYAN warp$_C_RESET"
        if command -qv warp-cli 2>/dev/null
          set -l ws (warp-cli status 2>/dev/null | string match -r 'Status update: (.+)' | string replace -r 'Status update: (.+)' '$1')
          if test "$ws" = Connected
            echo "    o status:    $_C_GREEN $ws$_C_RESET"
          else
            echo "    o status:    $_C_RED Disconnected$_C_RESET"
          end
        else
          echo "    o status:    $_C_RED Disconnected$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN bluetooth$_C_RESET"
        if systemctl is-active bluetooth >/dev/null 2>&1
          echo "    o status:    $_C_GREEN active$_C_RESET"
        else
          echo "    o status:    $_C_RED inactive$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN geoclue$_C_RESET"
        if systemctl list-units --all geoclue.service 2>/dev/null | grep -q geoclue
          if systemctl is-active geoclue >/dev/null 2>&1
            echo "    o status:    $_C_GREEN active$_C_RESET"
          else
            echo "    o status:    $_C_RED inactive$_C_RESET"
          end
        else
          echo "    o status:    $_C_DIM not installed$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN dns$_C_RESET"
        set -l srv (resolvectl status | string match -r 'Current DNS Server: .+' | string replace 'Current DNS Server: ' "")
        if test -n "$srv"
          echo "  server:$srv"
        end
        if command -qv resolvectl
          resolvectl query dnssec-failed.org >/dev/null 2>&1
          set -l dns_rc $status
          ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1
          if test $status -ne 0
            echo "    o dnssec:   $_C_DIM (no network)$_C_RESET"
          else if test $dns_rc -ne 0
            echo "    o dnssec:   $_C_GREEN ON$_C_RESET"
          else
            echo "    o dnssec:   $_C_RED OFF$_C_RESET"
          end
        end

        echo ""
        echo "  $_C_CYAN mac$_C_RESET"
        for iface in (command ls /sys/class/net)
          if test "$iface" != lo -a "$iface" != docker0 -a "$iface" != CloudflareWARP
            set -l m (cat /sys/class/net/$iface/address 2>/dev/null)
            set -l c (cat /sys/class/net/$iface/carrier 2>/dev/null)
            set -l r (nmcli -t -f cloned-mac-address connection show $iface 2>/dev/null | string match -r 'random')
            set -l s "down"
            if test "$c" = 1; set s up; end
            if test -n "$r"
              echo "  $iface: $_C_GREEN $m$_C_RESET randomized ($s)"
            else
              echo "  $iface: $_C_YELLOW $m$_C_RESET permanent ($s)"
            end
          end
        end

        echo ""
        echo "  $_C_CYAN ip$_C_RESET"
        set -l ip_cache /tmp/.topaz_ip_cache
        set -l data
        if test -f "$ip_cache"
          set -l age (math (date +%s) - (stat -c %Y "$ip_cache") 2>/dev/null)
          if test "$age" -lt 300 2>/dev/null
            set data (cat "$ip_cache")
          end
        end
        if test -z "$data"
          set data (curl -s --max-time 3 https://ipinfo.io/json 2>/dev/null)
          if test -n "$data"; printf '%s\n' "$data" >"$ip_cache"; end
        end
        set -l ip (printf '%s\n' "$data" | string match -r '"ip":\s*"[^"]*"' | string replace -r '.*"ip":\s*"([^"]*).*' '$1')
        set -l loc (printf '%s\n' "$data" | string match -r '"city":\s*"[^"]*"' | string replace -r '.*"city":\s*"([^"]*).*' '$1')
        set -l org (printf '%s\n' "$data" | string match -r '"org":\s*"[^"]*"' | string replace -r '.*"org":\s*"([^"]*).*' '$1')
        if test -n "$ip"
          echo "  public: $ip"
          echo "  city:   $loc"
          echo "  org:    $org"
        else
          echo "  public: $_C_DIM ?$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN weather$_C_RESET"
        set -l wthr_cache /tmp/.topaz_wthr_cache
        set -l w
        if test -f "$wthr_cache"
          set -l age (math (date +%s) - (stat -c %Y "$wthr_cache") 2>/dev/null)
          if test "$age" -lt 600 2>/dev/null
            set w (cat "$wthr_cache")
          end
        end
        if test -z "$w"
          set w (curl -s --max-time 3 "https://wttr.in?format=%C+%t+%w+%h")
          if test -n "$w"; printf '%s\n' "$w" >"$wthr_cache"; end
        end
        if test -n "$w"
          echo "  $w $_C_DIM(wttr.in)$_C_RESET"
        else
          echo "  $_C_DIM weather unavailable (run 'topaz weather' to fetch)$_C_RESET"
        end
      end

      # ─── AUDIT ─────────────────────────────────────────────

      function _topaz_audit --description 'Security audit'
        if test "$argv[1]" = -h -o "$argv[1]" = --help 2>/dev/null; echo "usage: topaz audit"; return 0; end
        _box "security audit"
        echo ""
        set -l issues 0
        set -l warnings 0

        echo "  $_C_MAGENTA firewall$_C_RESET"
        if doas iptables -C OUTPUT -j PROTON_KS 2>/dev/null
          echo "    $_C_GREEN v$_C_RESET killswitch: ACTIVE (ProtonVPN)"
        else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "    $_C_GREEN v$_C_RESET killswitch: ACTIVE (Tor)"
        else if doas nft list chain ip filter OUTPUT 2>/dev/null | string match -q drop
          echo "    $_C_GREEN v$_C_RESET firewall: nftables output rules"
        else if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_GREEN v$_C_RESET firewall: WARP daemon active"
        else
          set issues (math $issues + 1)
          echo "    $_C_RED x$_C_RESET NO OUTPUT RULES"
        end
        if ip6tables -L OUTPUT -n 2>/dev/null | string match -q DROP
          echo "    $_C_GREEN v$_C_RESET ipv6: blocked"
        else
          echo "    $_C_YELLOW ?$_C_RESET ipv6: OUTPUT allowed"
          set warnings (math $warnings + 1)
        end
        echo ""

        echo "  $_C_MAGENTA dns$_C_RESET"
        set -l srv (resolvectl status | string match -r 'Current DNS Server: .+' | string replace 'Current DNS Server: ' "")
        if test -n "$srv"
          if string match -q '127.0.0.1' -- $srv
            echo "    $_C_GREEN v$_C_RESET server: local ($srv)"
          else
            echo "    $_C_RED x$_C_RESET server: EXTERNAL ($srv)"
            set issues (math $issues + 1)
          end
        else
          echo "    $_C_YELLOW ?$_C_RESET server: unknown"
          set warnings (math $warnings + 1)
        end
        set -l d (resolvectl query dnssec-failed.org 2>&1)
        if test $status -ne 0
          echo "    $_C_GREEN v$_C_RESET dnssec: ON"
        else
          echo "    $_C_YELLOW ?$_C_RESET dnssec: OFF"
          set warnings (math $warnings + 1)
        end
        set -l resolvers (resolvectl dns 2>/dev/null | string replace -r '^\S+\s+' '' | string trim)
        if test -n "$resolvers"
          if string match -qr '127\.|192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.|0\.0\.0\.0' -- $resolvers
            echo "    $_C_GREEN v$_C_RESET dns: local resolver ($resolvers)"
          else
            echo "    $_C_RED x$_C_RESET DNS LEAK: external resolvers ($resolvers)"
            set issues (math $issues + 1)
          end
        end
        echo ""

        echo "  $_C_MAGENTA vpn/ip$_C_RESET"
        set -l any_tunnel 0
        if ip link show proton0 >/dev/null 2>&1
          echo "    $_C_GREEN v$_C_RESET vpn: connected"
          set any_tunnel 1
        end
        if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_GREEN v$_C_RESET warp: connected"
          set any_tunnel 1
        end
        if test $any_tunnel -eq 0
          echo "    $_C_RED x$_C_RESET no tunnel active"
          set issues (math $issues + 1)
        end
        echo ""

        echo "  $_C_MAGENTA exposed ports$_C_RESET"
        set -l exposed 0
        set -l high 0
        set -l seen
        ss -tulnp | string match -r '0\.0\.0\.0:\d+|\\*:\d+' | while read -l line
          set -l port (string match -r '\d+' $line | tail -1)
          if set -l idx (contains -i -- $port $seen) 2>/dev/null; continue; end
          set -a seen $port
          set exposed (math $exposed + 1)
          set -l risk LOW
          switch $port
            case 22; set risk LOW
            case 53 5353 5355; set risk MED
            case 80 443 8080 8443; set risk LOW
            case '*'; set risk HIGH; set high (math $high + 1)
          end
          if test $risk = HIGH
            set issues (math $issues + 1)
            echo "    $_C_RED HIGH$_C_RESET port $port"
          else if test $risk = MED
            echo "    $_C_YELLOW MED$_C_RESET  port $port"
          else
            echo "    $_C_GREEN LOW$_C_RESET  port $port"
          end
        end
        if test $exposed -eq 0
          echo "    $_C_GREEN v$_C_RESET no exposed ports"
        else
          echo "    ($exposed exposed, $high high risk)"
        end
        echo ""

        echo "  $_C_MAGENTA lan leaks$_C_RESET"
        if systemctl is-active avahi-daemon >/dev/null 2>&1
          echo "    $_C_YELLOW ?$_C_RESET avahi: RUNNING"
          set warnings (math $warnings + 1)
        else
          echo "    $_C_GREEN v$_C_RESET avahi: not running"
        end
        if systemctl is-active nmbd >/dev/null 2>&1
          echo "    $_C_YELLOW ?$_C_RESET nmbd: RUNNING"
          set warnings (math $warnings + 1)
        else
          echo "    $_C_GREEN v$_C_RESET nmbd: not running"
        end
        echo ""

        echo "  $_C_MAGENTA kernel hardening$_C_RESET"
        set -l rp (cat /proc/sys/net/ipv4/conf/all/rp_filter 2>/dev/null)
        set -l sc (cat /proc/sys/net/ipv4/tcp_syncookies 2>/dev/null)
        set -l ic (cat /proc/sys/net/ipv4/icmp_echo_ignore_all 2>/dev/null)
        if test "$rp" = 1
          echo "    $_C_GREEN v$_C_RESET rp_filter: ON"
        else
          echo "    $_C_YELLOW ?$_C_RESET rp_filter: OFF"
          set warnings (math $warnings + 1)
        end
        if test "$sc" = 1
          echo "    $_C_GREEN v$_C_RESET tcp_syncookies: ON"
        else
          echo "    $_C_YELLOW ?$_C_RESET tcp_syncookies: OFF"
          set warnings (math $warnings + 1)
        end
        if test "$ic" = 1
          echo "    $_C_GREEN v$_C_RESET icmp_echo: blocked"
        else
          echo "    $_C_DIM   icmp_echo: unrestricted$_C_RESET"
        end
        echo ""

        echo "  $_C_MAGENTA hardware$_C_RESET"
        set -l cam (ls /dev/video* 2>/dev/null)
        if test -n "$cam"
          echo "    $_C_YELLOW ?$_C_RESET webcam device(s) present: $cam"
        else
          echo "    $_C_GREEN v$_C_RESET no webcam"
        end
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | string match -q MUTED
          echo "    $_C_GREEN v$_C_RESET mic: muted"
        else
          echo "    $_C_YELLOW ?$_C_RESET mic: UNMUTED"
          set warnings (math $warnings + 1)
        end
        if systemctl is-active usbguard >/dev/null 2>&1
          echo "    $_C_GREEN v$_C_RESET usbguard: active"
        else
          echo "    $_C_RED x$_C_RESET usbguard: INACTIVE"
          set issues (math $issues + 1)
        end
        echo ""

        echo "  $_C_MAGENTA summary$_C_RESET"
        if test $issues -eq 0 -a $warnings -eq 0
          echo "    $_C_GREEN ✓ ALL CLEAR$_C_RESET — no issues detected"
        else
          test $issues -gt 0; and echo "    $_C_RED ✗ $issues critical issue$(test $issues -ne 1; and echo s)$_C_RESET"
          test $warnings -gt 0; and echo "    $_C_YELLOW ⚠ $warnings warning$(test $warnings -ne 1; and echo s)$_C_RESET"
        end
      end

      # ─── TRAFFIC BLEND ─────────────────────────────────────

      function record --description 'Record screen with wf-recorder'
        set -l output_dir ~/Videos
        set -l timestamp (date +%Y-%m-%d_%H-%M-%S)
        set -l filename "$output_dir/recording_$timestamp.mp4"
        set -l output_name eDP-1
        set -l geometry ""
        set -l no_audio 0

        argparse s/select A/area= o/output= f/file= a/no-audio h/help -- $argv
        or return 1

        if set -q _flag_help
          _box "screen recording"
          echo ""
          echo "  Usage: record [OPTIONS]"
          echo ""
          echo "  Options:"
          echo "    -o, --output <NAME>  Output to record $_C_DIM(default: eDP-1)$_C_RESET"
          echo "    -s, --select         Select a region $_C_DIM(uses slurp)$_C_RESET"
          echo "    -A, --area <GEO>     Geometry $_C_DIM(e.g. '1920x1080+0+0')$_C_RESET"
          echo "    -f, --file <FILE>    Output filename"
          echo "    -a, --no-audio       Record without audio"
          echo "    -h, --help           Show this help"
          return 0
        end

        set -q _flag_file; and set filename $_flag_file
        set -q _flag_output; and set output_name $_flag_output
        set -q _flag_area; and set geometry $_flag_area
        set -q _flag_no_audio; and set no_audio 1

        if set -q _flag_select
          if not command -q slurp
            echo "$_C_RED ✗$_C_RESET slurp not found $_C_DIM(install slurp for region selection)$_C_RESET"
            return 1
          end
          set geometry (slurp)
          or return 1
        end

        mkdir -p $output_dir

        set -l cmd wf-recorder -o $output_name -f "$filename"
        test -n "$geometry"; and set -a cmd -g "$geometry"
        test $no_audio -eq 0; and set -a cmd --audio

        _box "recording"
        echo "  $_C_DIM output: $_C_RESET$filename"
        echo "  $_C_DIM screen: $_C_RESET$output_name"
        test -n "$geometry"; and echo "  $_C_DIM area:   $_C_RESET$geometry"
        test $no_audio -eq 0; and echo "  $_C_DIM audio:  $_C_RESET yes" || echo "  $_C_DIM audio:  $_C_RESET no"
        echo ""

        notify-send -t 2000 "Recording started" "$filename"
        eval $cmd
        if test $status -eq 0
          set -l fsize (du -h "$filename" 2>/dev/null | string split -f1 ' ')
          notify-send -t 3000 "Recording saved" "$filename"
          echo "$_C_GREEN ✓$_C_RESET saved: $filename $_C_DIM($fsize)$_C_RESET"
        else
          notify-send -u critical "Recording failed" "wf-recorder exited with status $status"
          echo "$_C_RED ✗ recording failed$_C_RESET"
          return 1
        end
      end

      function rec-status --description 'Check if recording is active'
        if pgrep -x wf-recorder >/dev/null 2>&1
          set -l pid (pgrep -x wf-recorder)
          set -l elapsed (ps -o etimes= -p $pid 2>/dev/null | string trim)
          set -l mem (ps -o rss= -p $pid 2>/dev/null | string trim)
          echo "$_C_RED ● RECording  $_C_DIM(pid $pid, $elapsed""s, $mem""KB)$_C_RESET"
        else
          echo "$_C_GREEN ● not recording"
        end
      end

      function rec-on --description 'Quick start recording (wraps record -a)'
        if pgrep -x wf-recorder >/dev/null 2>&1
          echo "$_C_YELLOW ⚠$_C_RESET already recording — run 'rec-off' to stop"
          return 1
        end
        record -a $argv
      end

      function rec-off --description 'Stop recording'
        if pgrep -x wf-recorder >/dev/null 2>&1
          pkill -INT wf-recorder
          echo "$_C_GREEN ✓$_C_RESET recording stopped"
        else
          echo "$_C_DIM ○ not recording$_C_RESET"
        end
      end

      # ─── Nix helpers ──────────────────────────────────────

      function net-reset --description 'Flush all iptables and restore defaults'
        echo "$_C_CYAN ○$_C_RESET stopping killswitch service..."
        doas systemctl stop protonvpn-killswitch 2>/dev/null; or true
        sleep 1
        doas iptables -D OUTPUT -j PROTON_KS 2>/dev/null; or true
        doas iptables -F PROTON_KS 2>/dev/null; or true
        doas iptables -X PROTON_KS 2>/dev/null; or true
        echo "$_C_CYAN ○$_C_RESET flushing iptables..."
        doas iptables -F
        doas iptables -t nat -F
        doas iptables -X
        doas iptables -P OUTPUT ACCEPT
        doas ip6tables -P OUTPUT ACCEPT 2>/dev/null; or true
        echo "$_C_CYAN ○$_C_RESET disabling dnssec..."
        doas resolvectl dnssec wlan0 no 2>/dev/null; or true
        echo "$_C_CYAN ○$_C_RESET killing tor..."
        doas pkill -f "tor -f /etc/tor/torrc-obfs4" 2>/dev/null; or true
        set -e ALL_PROXY
        echo "$_C_GREEN ✓$_C_RESET net reset complete (firewall OFF)"
      end

      function dev --description 'Enter development shell'
        if test (count $argv) -lt 2
          echo "$_C_RED ✗$_C_RESET usage: dev <config-dir> <language>"
          echo "  $_C_DIM example: dev nixos-cfg rust$_C_RESET"
          return 1
        end
        set -l dir ~/$argv[1]/devenvs/$argv[2]
        if not test -d "$dir"
          echo "$_C_RED ✗$_C_RESET unknown devenv: $argv[2]"
          echo "  $_C_DIM available: $(ls ~/$argv[1]/devenvs/ 2>/dev/null | string join ', ')$_C_RESET"
          return 1
        end
        echo "$_C_CYAN ○$_C_RESET entering $_C_BOLD$argv[2]$_C_RESET devenv..."
        cd "$dir"; or return 1
        devenv shell
      end

      function gh-pr --description 'GitHub PR quick view (arg = repo, e.g. user/repo)'
        if test (count $argv) -eq 0
          echo "$_C_RED ✗$_C_RESET usage: gh-pr <owner/repo>"
          return 1
        end
        _box "open prs: $argv[1]"
        echo ""
        gh pr list --repo $argv[1] --state open --limit 15 2>/dev/null
        or echo "$_C_RED ✗$_C_RESET failed — is 'gh' authenticated?"
      end

      function flake-init --description 'Initialize a new NixOS flake'
        if test (count $argv) -lt 2
          echo "$_C_RED ✗$_C_RESET usage: flake-init <dir> <hostname>"
          echo "  $_C_DIM example: flake-init ~/nixos-cfg gentuwu$_C_RESET"
          return 1
        end
        set -l dir $argv[1]
        set -l hostname $argv[2]

        if test -f "$dir/flake.nix"
          echo "$_C_YELLOW ⚠$_C_RESET $dir/flake.nix already exists"
          return 1
        end

        mkdir -p "$dir/hosts/$hostname"
        printf '%s\n' \
          '{' \
          '  description = "NixOS system configuration";' \
          '  inputs = {' \
          '    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";' \
          '  };' \
          '  outputs = { self, nixpkgs, ... }: {' \
          "    nixosConfigurations.$hostname = nixpkgs.lib.nixosSystem {" \
          '      system = "x86_64-linux";' \
          '      modules = [ ./hosts/'"$hostname"'/configuration.nix ];' \
          '    };' \
          '  };' \
          '}' \
          > "$dir/flake.nix"

        printf '%s\n' \
          '{ config, pkgs, ... }:' \
          '{' \
          '  imports = [ ./hardware-configuration.nix ];' \
          '  boot.loader.systemd-boot.enable = true;' \
          '  boot.loader.efi.canTouchEfiVariables = true;' \
          '  networking.hostName = "'"$hostname"'";' \
          '  networking.networkmanager.enable = true;' \
          '  users.users.yari = { isNormalUser = true; extraGroups = [ "wheel" ]; };' \
          '  environment.systemPackages = with pkgs; [ vim wget ];' \
          '  system.stateVersion = "24.05";' \
          '}' \
          > "$dir/hosts/$hostname/configuration.nix"

        echo "$_C_GREEN ✓$_C_RESET flake initialized at $dir"
        echo "  $_C_DIM flake.nix$_C_RESET"
        echo "  $_C_DIM hosts/$hostname/configuration.nix$_C_RESET"
        echo ""
        echo "$_C_YELLOW ⚠$_C_RESET generate hardware-configuration.nix with:"
        echo "  $_C_DIM nixos-generate-config --show-hardware-config > $dir/hosts/$hostname/hardware-configuration.nix$_C_RESET"
      end

      # ─── Help ─────────────────────────────────────────────

      function help --description 'List all custom functions'
        echo ""
        _box "gentuwu command reference"
        echo ""

        echo "$_C_CYAN ── topaz suite ──$_C_RESET"
        echo "  $_C_GREEN●$_C_RESET topaz               TOPAZ security & privacy suite"
        echo "  $_C_GREEN●$_C_RESET topaz guide         All TOPAZ commands"
        echo ""

        echo "$_C_CYAN ── nixos ──$_C_RESET"
        type -q sysupd    && printf "  $_C_BLUE●$_C_RESET %-14s %s\n" sysupd    "Update flake & rebuild NixOS"
        type -q update    && printf "  $_C_BLUE●$_C_RESET %-14s %s\n" update    "Rebuild NixOS (no update)"
        type -q dev       && printf "  $_C_BLUE●$_C_RESET %-14s %s\n" dev       "Enter development shell"
        type -q flake-init && printf "  $_C_BLUE●$_C_RESET %-14s %s\n" flake-init "Initialize a new NixOS flake"
        echo ""

        echo "$_C_CYAN ── git ──$_C_RESET"
        type -q gp        && printf "  $_C_GREEN●$_C_RESET %-14s %s\n" gp        "Git add, commit, push"
        type -q gitwho    && printf "  $_C_BLUE●$_C_RESET %-14s %s\n" gitwho    "Set git identity"
        type -q gh-pr     && printf "  $_C_CYAN●$_C_RESET %-14s %s\n" gh-pr     "GitHub PR list"
        echo ""

        echo "$_C_CYAN ── recording ──$_C_RESET"
        type -q record    && printf "  $_C_RED●$_C_RESET %-14s %s\n" record    "Record screen (wf-recorder)"
        type -q rec-status && printf "  $_C_RED●$_C_RESET %-14s %s\n" rec-status "Check recording status"
        type -q rec-on    && printf "  $_C_RED●$_C_RESET %-14s %s\n" rec-on    "Start recording"
        type -q rec-off   && printf "  $_C_RED●$_C_RESET %-14s %s\n" rec-off   "Stop recording"
        echo ""

        echo "$_C_CYAN ── network ──$_C_RESET"
        type -q net-reset && printf "  $_C_YELLOW●$_C_RESET %-14s %s\n" net-reset "Flush iptables, restore defaults"
        type -q vpn-openvpn && printf "  $_C_CYAN●$_C_RESET %-14s %s\n" vpn-openvpn "Switch to OpenVPN TCP/443 (info)"
        echo ""

        echo "  run $_C_GREEN topaz guide$_C_RESET for all 30+ TOPAZ commands"
      end

      # ─── Tab Completions ──

      complete -c topaz -f -a "status" -d "Privacy & security dashboard"
      complete -c topaz -f -a "audit" -d "Security audit"
      complete -c topaz -f -a "tor" -d "Tor routing"
      complete -c topaz -f -a "vpn" -d "ProtonVPN"
      complete -c topaz -f -a "warp" -d "Cloudflare WARP"
      complete -c topaz -f -a "dns" -d "DNS settings"
      complete -c topaz -f -a "firewall" -d "Killswitch"
      complete -c topaz -f -a "microphone" -d "Mic control"
      complete -c topaz -f -a "webcam" -d "Webcam control"
      complete -c topaz -f -a "mac-randomizer" -d "MAC randomize"
      complete -c topaz -f -a "sysinfo" -d "System info"
      complete -c topaz -f -a "battery" -d "Battery status"
      complete -c topaz -f -a "weather" -d "Weather"
      complete -c topaz -f -a "disk" -d "Disk usage"
      complete -c topaz -f -a "processes" -d "Process monitor"
      complete -c topaz -f -a "cache" -d "Clear caches"
      complete -c topaz -f -a "ports" -d "Port listing, scanning, blocking"
      complete -c topaz -f -n '__fish_seen_subcommand_from ports' -a "list" -d "Show open ports"
      complete -c topaz -f -n '__fish_seen_subcommand_from ports' -a "scan" -d "Port scan target"
      complete -c topaz -f -n '__fish_seen_subcommand_from ports' -a "block" -d "Block a port"
      complete -c topaz -f -n '__fish_seen_subcommand_from ports' -a "unblock" -d "Unblock a port"
      complete -c topaz -f -a "mounts" -d "Mounts"
      complete -c topaz -f -a "tailscale" -d "Tailscale"
      complete -c topaz -f -a "what" -d "Identify command"
      complete -c topaz -f -a "recent" -d "Recent files"
      complete -c topaz -f -a "clean" -d "Wipe privacy traces"
      complete -c topaz -f -a "leaktest" -d "DNS & IP leak test"
      complete -c topaz -f -a "bluetooth" -d "Bluetooth control"
      complete -c topaz -f -a "geoclue" -d "Geolocation control"
      complete -c topaz -f -a "timeline" -d "Recent state changes"
      complete -c topaz -f -a "watch" -d "Live network traffic"
      complete -c topaz -f -a "guide" -d "All commands"
    
