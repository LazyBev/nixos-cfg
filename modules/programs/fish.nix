{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx LIBVIRT_DEFAULT_URI qemu:///system
      set -g fish_greeting
      set -gx EZA_COLORS "di=96:fi=37:ex=92:ln=95:or=91:mi=91:su=93:sf=93:wu=93:sg=93:pi=93:so=93:bd=94:cd=94"

      set -g _C_RED (printf '\e[38;2;255;80;80m')
      set -g _C_GREEN (printf '\e[38;2;120;220;120m')
      set -g _C_YELLOW (printf '\e[38;2;255;220;100m')
      set -g _C_BLUE (printf '\e[38;2;100;160;255m')
      set -g _C_MAGENTA (printf '\e[38;2;220;130;255m')
      set -g _C_CYAN (printf '\e[38;2;100;220;230m')
      set -g _C_WHITE (printf '\e[38;2;230;230;230m')
      set -g _C_BOLD (printf '\e[1m')
      set -g _C_DIM (printf '\e[2;38;2;130;130;130m')
      set -g _C_ITALIC (printf '\e[3m')
      set -g _C_RESET (printf '\e[0m')

      function _box --description 'Print a centered box header'
        set -l text $argv[1]
        set -l color (test (count $argv) -gt 1 && echo $argv[2] || echo "$_C_MAGENTA")
        set -l w 34
        set -l tl (string length -- "$text")
        set -l pl (math -s0 "($w - $tl) / 2")
        set -l pr (math "$w - $tl - $pl")
        echo "$color ╔$(string repeat -n $w '═')╗$_C_RESET"
        echo "$color ║$_C_RESET$(string repeat -n $pl ' ')$_C_BOLD$text$_C_RESET$(string repeat -n $pr ' ')""$color""║$_C_RESET"
        echo "$color ╚$(string repeat -n $w '═')╝$_C_RESET"
      end

      function doas --wraps doas
        if test "$argv" = "!!"
            command doas (history -n 1)
        else
            command doas $argv
        end
      end
      zoxide init fish | source

      function prevd
        if set -q __last_dir
          cd "$__last_dir"
        else
          echo "$_C_YELLOW ⚠$_C_RESET no previous directory"
        end
      end

      function cd
        set -gx __last_dir "$PWD"
        builtin cd $argv
      end

      function gitwho --description 'Set git user name and email'
        if test (count $argv) -lt 2
          echo "$_C_RED ✗$_C_RESET usage: gitwho <name> <email>"
          return 1
        end
        git config --global user.name "$argv[1]"
        git config --global user.email "$argv[2]"
        echo "$_C_GREEN ✓$_C_RESET git identity set"
        echo "  $_C_DIM name:$_C_RESET  $argv[1]"
        echo "  $_C_DIM email:$_C_RESET $argv[2]"
      end

      function gp --description 'Git add, commit, and push'
        if test (count $argv) -eq 0
          echo "$_C_RED ✗$_C_RESET usage: gp <commit message>"
          return 1
        end

        echo "$_C_CYAN ○$_C_RESET staging..."
        git add .; or return 1

        set -l changed (git diff --cached --shortstat 2>/dev/null | string match -r '\d+ files? changed' | string match -r '\d+')
        set -l insertions (git diff --cached --shortstat 2>/dev/null | string match -r '\d+ insertions?' | string match -r '\d+')
        set -l deletions (git diff --cached --shortstat 2>/dev/null | string match -r '\d+ deletions?' | string match -r '\d+')

        echo "$_C_CYAN ○$_C_RESET committing..."
        git commit -m "$argv" 2>&1 | while read -l line
          if string match -q '*nothing to commit*' $line
            echo "  $_C_YELLOW ⚠$_C_RESET nothing to commit"
            return 1
          end
          echo "  $line"
        end
        or return 1

        echo "$_C_CYAN ○$_C_RESET pushing..."
        git push 2>&1 | while read -l line
          echo "  $line"
        end
          and echo "$_C_GREEN ✓$_C_RESET $_C_BOLD pushed!$_C_RESET $_C_DIM($changed files, +$insertions -$deletions)""$_C_RESET"
      end

      function sysupd --description 'Update NixOS flake and rebuild'
        if test (count $argv) -lt 2
          echo "$_C_RED ✗$_C_RESET usage: sysupd <config-dir> <hostname>"
          echo "  $_C_DIM example: sysupd nixos-cfg gentuwu$_C_RESET"
          return 1
        end

        echo "$_C_MAGENTA ── nix flake update ──$_C_RESET"
        pushd ~/$argv[1]; or return 1
        nix flake update 2>&1 | while read -l line
          echo "  $line"
        end
        or begin; popd; return 1; end

        echo ""
        echo "$_C_MAGENTA ── nh os switch ──$_C_RESET"
        nh os switch ".#$argv[2]"
        set -l rc $status
        popd

        if test $rc -eq 0
          echo ""
          echo "$_C_GREEN ✓$_C_RESET $_C_BOLD system updated!$_C_RESET"
        else
          echo "$_C_RED ✗$_C_RESET rebuild failed (exit $rc)"
        end
        return $rc
      end

      function update --description 'Rebuild NixOS without updating flake'
        if test (count $argv) -lt 2
          echo "$_C_RED ✗$_C_RESET usage: update <config-dir> <hostname>"
          echo "  $_C_DIM example: update nixos-cfg gentuwu$_C_RESET"
          return 1
        end
        echo "$_C_CYAN ○$_C_RESET rebuilding..."
        nh os switch $HOME/$argv[1]#$argv[2]
        and echo "$_C_GREEN ✓$_C_RESET $_C_BOLD system updated!$_C_RESET"
      end

      function irc --wraps=weechat
        command weechat $argv
      end

      function catgirl --wraps=catgirl
        command catgirl config $argv
      end

      function vpn-openvpn --description 'Switch ProtonVPN to OpenVPN TCP/443 (looks like HTTPS)'
        _box "OpenVPN TCP/443"
        echo ""
        echo "$_C_CYAN ○$_C_RESET switching ProtonVPN protocol to OpenVPN TCP..."
        echo ""
        echo "$_C_YELLOW ⚠$_C_RESET this requires the ProtonVPN GUI:"
        echo "  1. Open ProtonVPN → Settings → Connection"
        echo "  2. Protocol → OpenVPN (TCP)"
        echo "  3. Port → 443 (default)"
        echo "  4. Reconnect"
        echo ""
        echo "$_C_DIM OpenVPN TCP on port 443 wraps traffic in TLS on port 443$_C_RESET"
        echo "$_C_DIM making it look like HTTPS to basic DPI systems$_C_RESET"
        echo ""
        echo "$_C_DIM note: ProtonVPN Stealth (WireGuard over TLS) is better$_C_RESET"
        echo "$_C_DIM but requires v4.17.1 which isn't on NixOS yet$_C_RESET"

        if pgrep -x proton-vpn >/dev/null 2>&1
          echo ""
          echo "$_C_YELLOW ⚠$_C_RESET proton-vpn is running — restart after changing settings"
        end
      end

      # ─── TOPAZ ────────────────────────────────────────────

      set -g TOPAZ_VERSION '2.1.0'

      function _check_tool --description 'Check if a required tool is available'
        if not command -qv $argv[1] >/dev/null 2>&1
          echo "$_C_RED x$_C_RESET $_C_BOLD$argv[1]$_C_RESET not found"
          if test (count $argv) -ge 2
            echo "  $_C_DIM install: $argv[2]$_C_RESET"
          end
          return 1
        end
        return 0
      end

      function _check_doas --description 'Check doas availability'
        if not command -qv doas >/dev/null 2>&1
          echo "$_C_RED x$_C_RESET $_C_BOLD doas$_C_RESET not found (needs root privileges)"
          return 1
        end
        return 0
      end

      function topaz --description 'TOPAZ Suite - security & privacy tools'
        switch (count $argv)
          case 0
            _topaz_guide
          case '*'
            switch $argv[1]
              case status;      _topaz_status
              case audit;       _topaz_audit
              case traffic-blend traffic_blend; _topaz_blend
              case tor;         _topaz_tor $argv[2..]
              case vpn;         _topaz_vpn $argv[2..]
              case warp;        _topaz_warp $argv[2..]
              case dns;         _topaz_dns $argv[2..]
              case firewall fw; _topaz_fw $argv[2..]
              case block;       _topaz_block $argv[2..]
              case unblock;     _topaz_unblock $argv[2..]
              case microphone mic; _topaz_mic $argv[2..]
              case webcam cam;  _topaz_cam $argv[2..]
              case mac-randomizer mac-randomiser mac; _topaz_mac $argv[2..]
              case clamav scan; _topaz_clamav $argv[2..]
              case url-check urlcheck url; _topaz_urlcheck $argv[2..]
              case sysinfo;     _topaz_sysinfo
              case battery;     _topaz_battery
              case weather;     _topaz_weather $argv[2..]
              case disk;        _topaz_disk
              case processes procs; _topaz_procs $argv[2..]
              case cache;       _topaz_cache $argv[2..]
              case ports;       _topaz_ports $argv[2..]
              case scanports;   _topaz_scanports $argv[2..]
              case ssh-audit ssh_audit; _topaz_ssh_audit
              case mounts;      _topaz_mounts
              case tailscale;   _topaz_tailscale
              case what;        _topaz_what $argv[2..]
              case recent;      _topaz_recent $argv[2..]
              case relink;      _topaz_relink
              case record-status record_on record_off record_on rec_on rec_off
                _topaz_record $argv[1]
              case guide help -h --help; _topaz_guide
              case -v --version version; _topaz_version
              case '*'
                echo "$_C_RED x$_C_RESET unknown: $argv[1]"
                echo "  run $_C_BOLD topaz guide$_C_RESET for commands"
                return 1
            end
        end
      end

      function _topaz_version --description 'Show TOPAZ version'
        echo "topaz $TOPAZ_VERSION"
      end

      function _topaz_tor --description 'Tor routing'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz tor <on|off|status>"
          return 1
        end
        _check_doas; or return 1
        switch $argv[1]
          case on
            if test -f /etc/tor/torrc-obfs4
              doas pkill -x tor 2>/dev/null
              doas tor -f /etc/tor/torrc-obfs4 --RunAsDaemon 1
              echo "$_C_GREEN v$_C_RESET tor obfs4 started"
            else
              doas systemctl start tor
              echo "$_C_GREEN v$_C_RESET tor started"
            end
          case off
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
          case on
            if command -v protonvpn-app >/dev/null 2>&1
              protonvpn-app &
              echo "$_C_GREEN v$_C_RESET launching ProtonVPN GUI"
            else
              echo "$_C_YELLOW ?$_C_RESET install protonvpn or use warp/tor instead"
            end
          case off
            pkill protonvpn-app 2>/dev/null
            doas systemctl stop protonvpn-killswitch 2>/dev/null
            echo "$_C_GREEN v$_C_RESET protonvpn stopped"
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
          case on
            warp-cli connect 2>&1
            and echo "$_C_GREEN v$_C_RESET WARP connected"
          case off
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
          case on
            doas resolvectl dnssec wlan0 yes
            echo "$_C_GREEN v$_C_RESET DNSSEC enabled"
          case off
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
        _check_doas; or return 1
        switch $argv[1]
          case on
            doas iptables -P OUTPUT DROP
            doas iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
            doas iptables -A OUTPUT -o lo -j ACCEPT
            doas iptables -A OUTPUT -p udp --dport 2408 -j ACCEPT
            echo "$_C_GREEN v$_C_RESET killswitch ON (DROP policy, allow EST/lo/WARP)"
          case off
            doas iptables -P OUTPUT ACCEPT
            doas iptables -F OUTPUT
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
        end
      end

      function _topaz_block --description 'Block a port'
        _check_doas; or return 1
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz block <port> [tcp|udp|both]"
          return 1
        end
        set -l port $argv[1]
        set -l proto tcp
        if test (count $argv) -ge 2
          set proto $argv[2]
        end
        if test "$proto" = both
          doas iptables -A OUTPUT -p tcp --dport $port -j DROP
          doas iptables -A OUTPUT -p udp --dport $port -j DROP
          echo "$_C_GREEN v$_C_RESET blocked $port (tcp+udp)"
        else
          doas iptables -A OUTPUT -p $proto --dport $port -j DROP
          echo "$_C_GREEN v$_C_RESET blocked $port/$proto"
        end
      end

      function _topaz_unblock --description 'Unblock a port'
        _check_doas; or return 1
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz unblock <port> [tcp|udp|both]"
          return 1
        end
        set -l port $argv[1]
        set -l proto tcp
        if test (count $argv) -ge 2
          set proto $argv[2]
        end
        if test "$proto" = both
          doas iptables -D OUTPUT -p tcp --dport $port -j DROP 2>/dev/null
          doas iptables -D OUTPUT -p udp --dport $port -j DROP 2>/dev/null
          echo "$_C_GREEN v$_C_RESET unblocked $port (tcp+udp)"
        else
          doas iptables -D OUTPUT -p $proto --dport $port -j DROP 2>/dev/null
          echo "$_C_GREEN v$_C_RESET unblocked $port/$proto"
        end
      end

      function _topaz_mic --description 'Microphone privacy'
        if test (count $argv) -lt 1
          echo "$_C_RED x$_C_RESET usage: topaz mic <on|off|status>"
          return 1
        end
        _check_tool wpctl "PipeWire (wireplumber)"; or return 1
        switch $argv[1]
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
            set -l mode (nmcli -t -f cloned-mac-address connection show wlan0 2>/dev/null | string split ':' | string trim)
            if test "$mode" = random
              echo "  wlan0: $_C_GREEN randomized$_C_RESET $mac"
            else
              echo "  wlan0: $_C_YELLOW permanent$_C_RESET $mac"
            end
        end
      end

      function _topaz_clamav --description 'Scan files with ClamAV'
        set -l targets ~/Downloads
        if test (count $argv) -ge 1
          set targets $argv
        end
        if not command -qv clamscan
          echo "$_C_RED x$_C_RESET ClamAV not installed"
          return 1
        end
        echo "$_C_CYAN o$_C_RESET scanning "(count $targets)" target(s)..."
        clamscan -r --bell --infected $targets
        and echo "$_C_GREEN v$_C_RESET no threats found"
      end

      function _topaz_urlcheck --description 'Check URL against threat feeds'
        if test (count $argv) -eq 0
          echo "$_C_RED x$_C_RESET usage: topaz url-check <url>"
          return 1
        end
        echo "$_C_CYAN o$_C_RESET checking $argv[1]..."
        curl -s "https://www.virustotal.com/vtapi/v2/url/report?apikey=demo&resource=$argv[1]" | string match -r '"positives":\d+|"scan_date":"[^"]*"'
        or echo "  $_C_DIM (check failed - no API key?)$_C_RESET"
      end

      function _topaz_sysinfo --description 'System info'
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

      function _topaz_ports --description 'Show open ports'
        set -l filter ""
        set -l proto ""
        for arg in $argv
          switch $arg
            case '-p' '--proto'
            case '*'
              if test -z "$proto"
                set proto $arg
              else
                set filter $arg
              end
          end
        end
        if test -n "$proto"
          ss -tulnp | string match -r "$proto" | head -30
        else if test -n "$filter"
          ss -tulnp | string match -r ":$filter " | head -30
        else
          ss -tulnp | head -30
        end
      end

      function _topaz_scanports --description 'TCP/UDP port scanner'
        set -l target "127.0.0.1"
        set -l threads 4
        set -l range ""
        set -l udp 0
        set -l i 2
        while test $i -le (count $argv)
          switch $argv[$i]
            case '-t' '--threads'; set i (math $i + 1); set threads $argv[$i]
            case '-r' '--range'; set i (math $i + 1); set range $argv[$i]
            case '-u' '--udp'; set udp 1
          end
          set i (math $i + 1)
        end
        if test (count $argv) -ge 1
          set target $argv[1]
        end
        set -l cmd "nmap -T4 -n"
        if test $udp -eq 1
          set cmd "$cmd -sU"
        else
          set cmd "$cmd -sT"
        end
        if test -n "$range"
          set cmd "$cmd -p $range"
        end
        if not command -qv nmap
          echo "$_C_YELLOW ?$_C_RESET nmap not installed, trying rustscan..."
          if command -qv rustscan
            rustscan -a $target $range
          else
            echo "$_C_RED x$_C_RESET install nmap for port scanning"
            return 1
          end
        else
          eval $cmd $target
        end
      end

      function _topaz_ssh_audit --description 'SSH config audit'
        if test -f /etc/ssh/sshd_config
          echo "  $_C_MAGENTA SSH config audit$_C_RESET"
          for line in PermitRootLogin PasswordAuthentication PubkeyAuthentication ChallengeResponseAuthentication Port Protocol
            set -l val (grep -i "^$line" /etc/ssh/sshd_config 2>/dev/null | head -1)
            if test -n "$val"
              echo "  $_C_DIM $line:$_C_RESET $val"
            end
          end
          echo ""
          if grep -qi 'PermitRootLogin yes' /etc/ssh/sshd_config 2>/dev/null
            echo "  $_C_RED x$_C_RESET root login enabled"
          end
          if grep -qi 'PasswordAuthentication yes' /etc/ssh/sshd_config 2>/dev/null
            echo "  $_C_YELLOW ?$_C_RESET password auth enabled"
          end
        else
          echo "  $_C_DIM no SSH server configured$_C_RESET"
        end
      end

      function _topaz_mounts --description 'Show mounted filesystems'
        mount | string match -r '^/' | while read -l line
          set -l parts (string split ' ' $line)
          echo "  $parts[1]  ->  $parts[3]"
        end
      end

      function _topaz_tailscale --description 'Tailscale status'
        if command -qv tailscale
          tailscale status 2>&1 | head -20
        else
          echo "$_C_DIM tailscale not installed$_C_RESET"
        end
      end

      function _topaz_what --description 'Identify a command or file'
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

      function _topaz_relink --description 'Fix broken nix store symlinks after GC'
        echo "$_C_CYAN o$_C_RESET scanning for broken symlinks..."
        find /run/current-system/sw/bin /nix/var/nix/profiles -type l ! -exec test -e {} \; -print 2>/dev/null | head -20
        echo "$_C_DIM (run 'nix store optimise' + reboot to fully fix)$_C_RESET"
      end

      function _topaz_record --description 'Recording shortcuts'
        switch $argv[1]
          case record-status rec_status; rec-status
          case record-on rec_on; rec-on
          case record-off rec_off; rec-off
        end
      end

      function _topaz_guide --description 'List all TOPAZ commands'
        _box "TOPAZ commands"
        echo ""
        echo "$_C_CYAN ==== NETWORK ====$_C_RESET"
        _tgd "tor on|off|status" "Tor routing with obfs4 bridges"
        _tgd "vpn on|off|status|openvpn" "ProtonVPN management"
        _tgd "warp on|off|status" "Cloudflare WARP (MASQUE/QUIC)"
        _tgd "dns on|off|leak|status" "DNSSEC & DNS leak test"
        echo ""
        echo "$_C_CYAN ==== FIREWALL ====$_C_RESET"
        _tgd "firewall on|off|status" "Killswitch management"
        _tgd "block <port> [tcp|udp|both]" "Block an outbound port"
        _tgd "unblock <port> [tcp|udp|both]" "Unblock a port"
        echo ""
        echo "$_C_CYAN ==== PRIVACY ====$_C_RESET"
        _tgd "microphone on|off|status" "Mic mute control"
        _tgd "webcam on|off|status" "Webcam permission block"
        _tgd "mac-randomizer on|off|status" "MAC address randomization"
        echo ""
        echo "$_C_CYAN ==== ANALYSIS ====$_C_RESET"
        _tgd "status" "Privacy & security dashboard"
        _tgd "audit" "Comprehensive security audit"
        _tgd "traffic-blend" "Traffic pattern analysis"
        _tgd "ssh-audit" "SSH config security check"
        echo ""
        echo "$_C_CYAN ==== SYSTEM ====$_C_RESET"
        _tgd "sysinfo" "System resources"
        _tgd "battery" "Battery status"
        _tgd "weather [city] [-f]" "Weather report"
        _tgd "disk" "Disk & nix store usage"
        _tgd "processes [N] [-t]" "Process monitor (N=count, -t=tree)"
        _tgd "cache [-f] [-n]" "Clear caches (-f: nix GC)"
        echo ""
        echo "$_C_CYAN ==== NET TOOLS ====$_C_RESET"
        _tgd "ports [port] [-p proto]" "Show open listening ports"
        _tgd "scanports <target> [-t N] [-r R] [-u]" "Port scanner"
        _tgd "tailscale" "Tailscale status"
        _tgd "url-check <url>" "Check URL against threat feeds"
        echo ""
        echo "$_C_CYAN ==== FILES ====$_C_RESET"
        _tgd "clamav [paths...]" "Scan files with ClamAV"
        _tgd "mounts" "Show mounted filesystems"
        _tgd "recent [files|cmds] [N]" "Recent files or commands"
        _tgd "what <target>" "Identify command/file"
        _tgd "relink" "Find broken nix symlinks"
        echo ""
        echo "$_C_DIM also: rec-status, rec-on, rec-off (standalone)$_C_RESET"
      end

      function _tgd --no-scope-shadowing --description 'Guide helper'
        printf "  $_C_GREEN o$_C_RESET $_C_BOLD%-24s$_C_RESET %s\n" $argv[1] $argv[2]
      end

      # ─── STATUS ────────────────────────────────────────────

      function _topaz_status --description 'Privacy & security dashboard'
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
        if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    o status:    $_C_GREEN connected$_C_RESET"
        else
          echo "    o status:    $_C_RED Disconnected$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN dns$_C_RESET"
        set -l srv (resolvectl status | string match -r 'Current DNS Server: .+' | string replace 'Current DNS Server: ' "")
        if test -n "$srv"
          echo "  server:$srv"
        end
        set -l d (resolvectl query dnssec-failed.org 2>&1; echo $status)
        if test $d[2] -ne 0
          echo "    o dnssec:   $_C_GREEN ON$_C_RESET"
        else
          echo "    o dnssec:   $_C_RED OFF$_C_RESET"
        end

        echo ""
        echo "  $_C_CYAN mac$_C_RESET"
        for iface in (command ls /sys/class/net)
          if test "$iface" != lo -a "$iface" != docker0
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
          echo "  $w"
        else
          echo "  $_C_DIM (run 'topaz weather' to fetch)$_C_RESET"
        end
      end

      # ─── AUDIT ─────────────────────────────────────────────

      function _topaz_audit --description 'Security audit'
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
        set -l leak (curl -s --max-time 5 https://ipleak.net/json/ 2>/dev/null | string match -r '"dns":"[^"]*"' | string replace -r '.*"dns":"([^"]*).*' '$1')
        if test -n "$leak"
          if string match -qr '127\.|192\.168\.|10\.' -- $leak
            echo "    $_C_GREEN v$_C_RESET dns leak test: passed ($leak)"
          else
            echo "    $_C_RED x$_C_RESET DNS LEAK: $leak"
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
          echo "    $_C_GREEN v$_C_RESET ALL CLEAR"
        else
          test $issues -gt 0; and echo "    $_C_RED $issues critical issues$_C_RESET"
          test $warnings -gt 0; and echo "    $_C_YELLOW $warnings warnings$_C_RESET"
        end
      end

      # ─── TRAFFIC BLEND ─────────────────────────────────────

      function _topaz_blend --description 'Traffic blend analysis'
        _box "traffic blend analysis"
        echo ""

        echo "  $_C_MAGENTA transport layer$_C_RESET"
        for t in WARP Tor ProtonVPN
          switch $t
            case WARP
              if ip link show CloudflareWARP >/dev/null 2>&1
                echo "    $_C_GREEN o$_C_RESET WARP"
              else
                echo "    $_C_DIM o$_C_RESET WARP"
              end
            case Tor
              if pgrep -x tor >/dev/null 2>&1
                echo "    $_C_GREEN o$_C_RESET Tor"
              else
                echo "    $_C_DIM o$_C_RESET Tor"
              end
            case ProtonVPN
              if ip link show proton0 >/dev/null 2>&1
                echo "    $_C_GREEN o$_C_RESET ProtonVPN"
              else
                echo "    $_C_DIM o$_C_RESET ProtonVPN"
              end
          end
        end
        echo ""

        echo "  $_C_MAGENTA dns chain$_C_RESET"
        set -l tunneled 0
        if ip link show CloudflareWARP >/dev/null 2>&1
          set tunneled 1
        else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          set tunneled 1
        end
        if test $tunneled -eq 1
          echo "    $_C_GREEN v$_C_RESET DNS: tunneled through WARP/Tor"
        else
          set -l srv (resolvectl status | string match -r 'Current DNS Server: .+' | string replace 'Current DNS Server: ' "")
          if string match -q '127.0.0.1' -- $srv
            echo "    $_C_GREEN v$_C_RESET resolver: local ($srv)"
          else if test -n "$srv"
            echo "    $_C_YELLOW ?$_C_RESET resolver: external ($srv)"
          end
          if resolvectl query dnssec-failed.org 2>&1; test $status -ne 0
            echo "    $_C_GREEN v$_C_RESET DNSSEC: ON"
          else
            echo "    $_C_YELLOW ?$_C_RESET DNSSEC: OFF"
          end
        end
        echo ""

        echo "  $_C_MAGENTA mac identity$_C_RESET"
        for iface in (ls /sys/class/net | grep -vE '^lo$|^docker')
          set -l m (cat /sys/class/net/$iface/address 2>/dev/null)
          set -l c (cat /sys/class/net/$iface/carrier 2>/dev/null)
          set -l r (nmcli -t -f cloned-mac-address connection show $iface 2>/dev/null | string match -r 'random')
          set -l s down
          test "$c" = 1; and set s up
          if test -n "$r"
            echo "    $iface: $_C_GREEN randomized$_C_RESET $m ($s)"
          else
            echo "    $iface: $_C_YELLOW permanent$_C_RESET $m ($s)"
          end
        end
        echo ""

        echo "  $_C_MAGENTA firewall posture$_C_RESET"
        if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_GREEN v$_C_RESET WARP daemon active"
        else if doas iptables -C OUTPUT -j PROTON_KS 2>/dev/null
          echo "    $_C_GREEN v$_C_RESET killswitch: ON (ProtonVPN)"
        else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "    $_C_GREEN v$_C_RESET killswitch: ON (Tor)"
        else
          echo "    $_C_YELLOW ?$_C_RESET no killswitch detected"
        end
        if ip6tables -L OUTPUT -n 2>/dev/null | string match -q DROP
          echo "    $_C_GREEN v$_C_RESET ipv6: blocked"
        else
          echo "    $_C_YELLOW ?$_C_RESET ipv6: allowed"
        end
        echo ""

        echo "  $_C_MAGENTA traffic profile$_C_RESET"
        set -l total (ss -tunaip | string length)
        if test $total -gt 100
          set -l tcp (ss -tna | wc -l)
          set -l udp (ss -una | wc -l)
          set -l port443 (ss -tna | string match -r ':443' | wc -l)
          echo "    $_C_DIM connections:$_C_RESET "(math $tcp + $udp)" (TCP: $tcp, UDP: $udp)"
          if test $port443 -gt 0
            echo "    $_C_DIM on port 443:$_C_RESET $port443"
          end
        else
          echo "    $_C_DIM (no active connections)$_C_RESET"
        end
        echo ""

        echo "  $_C_MAGENTA browser leaks$_C_RESET"
        for f in ~/.librewolf/*/prefs.js ~/.mozilla/firefox/*/prefs.js
          if test -f $f
            if grep -q 'media.peerconnection.enabled.*false' $f 2>/dev/null
              echo "    $_C_GREEN v$_C_RESET WebRTC: disabled"
            else
              echo "    $_C_YELLOW ?$_C_RESET WebRTC: ENABLED"
            end
            break
          end
        end
        echo ""

        echo "  $_C_MAGENTA what your ISP/DPI sees$_C_RESET"
        if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    protocol:  MASQUE/QUIC (encrypted, TLS-wrapped)"
          echo "    DPI sees:  HTTPS/QUIC traffic"
          echo "    masking:   $_C_GREEN strong$_C_RESET"
        else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "    protocol:  Tor (encrypted)"
          echo "    DPI sees:  Tor entry guard"
          echo "    masking:   $_C_YELLOW moderate$_C_RESET"
        else if ip link show proton0 >/dev/null 2>&1
          echo "    protocol:  VPN (encrypted)"
          echo "    DPI sees:  VPN tunnel"
          echo "    masking:   $_C_YELLOW weak$_C_RESET"
        else
          echo "    protocol:  none (direct)"
          echo "    DPI sees:  ALL traffic"
          echo "    masking:   $_C_RED none$_C_RESET"
        end
        echo ""

        echo "  $_C_MAGENTA verdict$_C_RESET"
        if ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_GREEN STRONG$_C_RESET -- traffic blends with HTTPS"
        else if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "    $_C_GREEN GOOD$_C_RESET -- traffic encrypted"
        else if ip link show proton0 >/dev/null 2>&1
          echo "    $_C_YELLOW MODERATE$_C_RESET -- VPN detectable"
        else
          echo "    $_C_RED WEAK$_C_RESET -- no protection"
        end
        echo ""
        echo "  $_C_DIM recommendations:$_C_RESET"
        if not ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_DIM o enable WARP for HTTPS-like traffic masking$_C_RESET"
        end
        if not ip link show proton0 >/dev/null 2>&1 -a not ip link show CloudflareWARP >/dev/null 2>&1
          echo "    $_C_DIM o connect VPN or WARP for encryption$_C_RESET"
        end
      end

      # ─── Recording (standalone) ────────────────────────────

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
        echo "$_C_CYAN ○$_C_RESET flushing iptables..."
        doas iptables -F
        doas iptables -t nat -F
        doas iptables -X
        doas ip6tables -P OUTPUT ACCEPT 2>/dev/null; or true
        echo "$_C_CYAN ○$_C_RESET disabling dnssec..."
        doas resolvectl dnssec wlan0 no
        echo "$_C_CYAN ○$_C_RESET killing tor..."
        sudo pkill -f "tor -f /etc/tor/torrc-obfs4" 2>/dev/null; or true
        set -e ALL_PROXY
        echo "$_C_CYAN ○$_C_RESET restoring vpn..."
        sudo systemctl start protonvpn-killswitch 2>/dev/null; or true
        echo "$_C_GREEN ✓$_C_RESET all flushed, vpn restored"
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

      # ─── Tab Completions (for remaining fish functions) ──

      complete -c sysupd -d "Update & rebuild NixOS" -r
      complete -c update -d "Rebuild NixOS" -r
      complete -c dev -d "Enter dev shell" -r
      complete -c record -d "Record screen" -s o -l output -r -d "Output name"
      complete -c record -s s -l select -d "Select region"
      complete -c record -s A -l area -r -d "Geometry"
      complete -c record -s f -l file -r -d "Output file"
      complete -c record -s a -l no-audio -d "No audio"
      complete -c record -s h -l help -d "Show help"
      complete -c gp -d "Git add, commit, push" -r
      complete -c gitwho -d "Set git user" -r
      complete -c gh-pr -d "GitHub PR list" -r
      complete -c flake-init -d "Initialize NixOS flake" -r
      complete -c rec-status -d "Check recording status"
      complete -c rec-on -d "Start recording"
      complete -c rec-off -d "Stop recording"
      complete -c net-reset -d "Flush iptables"
      complete -c vpn-openvpn -d "Switch to OpenVPN TCP/443"
      complete -c help -d "List all functions"
      complete -c topaz -f -a "status" -d "Privacy & security dashboard"
      complete -c topaz -f -a "audit" -d "Security audit"
      complete -c topaz -f -a "traffic-blend" -d "Traffic analysis"
      complete -c topaz -f -a "tor" -d "Tor routing"
      complete -c topaz -f -a "vpn" -d "ProtonVPN"
      complete -c topaz -f -a "warp" -d "Cloudflare WARP"
      complete -c topaz -f -a "dns" -d "DNS settings"
      complete -c topaz -f -a "firewall" -d "Killswitch"
      complete -c topaz -f -a "block" -d "Block port"
      complete -c topaz -f -a "unblock" -d "Unblock port"
      complete -c topaz -f -a "microphone" -d "Mic control"
      complete -c topaz -f -a "webcam" -d "Webcam control"
      complete -c topaz -f -a "mac-randomizer" -d "MAC randomize"
      complete -c topaz -f -a "clamav" -d "ClamAV scan"
      complete -c topaz -f -a "url-check" -d "URL threat check"
      complete -c topaz -f -a "sysinfo" -d "System info"
      complete -c topaz -f -a "battery" -d "Battery status"
      complete -c topaz -f -a "weather" -d "Weather"
      complete -c topaz -f -a "disk" -d "Disk usage"
      complete -c topaz -f -a "processes" -d "Process monitor"
      complete -c topaz -f -a "cache" -d "Clear caches"
      complete -c topaz -f -a "ports" -d "Open ports"
      complete -c topaz -f -a "scanports" -d "Port scanner"
      complete -c topaz -f -a "ssh-audit" -d "SSH audit"
      complete -c topaz -f -a "mounts" -d "Mounts"
      complete -c topaz -f -a "tailscale" -d "Tailscale"
      complete -c topaz -f -a "what" -d "Identify command"
      complete -c topaz -f -a "recent" -d "Recent files"
      complete -c topaz -f -a "relink" -d "Fix nix symlinks"
      complete -c topaz -f -a "guide" -d "All commands"
    '';
    shellAliases = {
      cat = "bat -p";
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza -la --icons --tree --level=2";
      grep = "rg";
      py = "python3";
      nv = "doas hx";
      gc = "doas nix-collect-garbage -d && doas nix-collect-garbage --delete-old && nix store optimise";
    };
    shellAbbrs = {
      nix = "nix";
      flake = "nix flake";
    };
  };
}
