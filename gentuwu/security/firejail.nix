{ pkgs, config, ... }: {
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      librewolf = {
        executable = "${config.programs.firefox.finalPackage}/bin/librewolf";
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
}
