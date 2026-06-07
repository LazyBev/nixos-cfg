{ pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    # TUI / terminal
    btop delta yazi
    kitty
    zathura imv mpv
    rmpc cava
    lazygit links2 browsh
    gh pay-respects

    # GUI / desktop
    fuzzel
    vscodium
    thunar thunar-archive-plugin thunar-volman tumbler
    networkmanagerapplet
    gtklock
    qutebrowser
    tor-browser
    steam
    proton-vpn protonmail-desktop

    # Dev / AI
    opencode
    ollama
    ocamlPackages.ocaml ocamlPackages.dune_3
    ocamlPackages.findlib ocamlPackages.ocaml-lsp
    devenv

    # Virtualisation
    qemu qemu_full

    # Media / file preview
    poppler chafa ffmpegthumbnailer
    libnotify

    # Themes
    catppuccin-sddm catppuccin-cursors.mochaMauve
    dracula-theme dracula-icon-theme

    # Noctalia
    (inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings =
        (builtins.fromJSON
          (builtins.readFile ../../../configs/apps/noctalia/noctalia.json)).settings;
    })
  ];
}
