{ pkgs, config, ... }:
let
  topazVendor = pkgs.runCommand "topaz-vendor-functions" {} ''
    mkdir -p $out/share/fish/vendor_functions.d
    cp ${./topaz-functions.fish} $out/share/fish/vendor_functions.d/topaz.fish
  '';
in {
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

      # ─── TOPAZ (external file) ───────────────────────────
      source ${./topaz-functions.fish}

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
  environment.systemPackages = [ topazVendor ];
}
