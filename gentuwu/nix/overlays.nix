_: {
  nixpkgs.overlays = [
    (
      final: prev:
      let
        beaker-src = builtins.fetchGit {
          url = "https://git.bwaaa.monster/beaker";
          rev = "3fab89ecf8f4c664477a82add660d28db87357b4";
        };
      in
      {
        beaker = prev.stdenv.mkDerivation {
          pname = "beaker";
          version = "git";
          src = beaker-src;
          makeFlags = [
            "INSTALL_PREFIX=$(out)/"
            "LDCONFIG=true"
          ];
        };
      }
    )
    (final: prev: {
      pragmasevka-nerd-font = prev.stdenvNoCC.mkDerivation {
        pname = "pragmasevka-nerd-font";
        version = "1.7.0";
        src = prev.fetchurl {
          url = "https://github.com/shytikov/pragmasevka/releases/download/v1.7.0/Pragmasevka_NF.zip";
          hash = "sha256-7qt1jv9WLRyu12EkRIjlZUW+Jegaa0DNhLMbAyo3YVw=";
        };
        nativeBuildInputs = [ prev.unzip ];
        unpackPhase = "unzip $src -d pragmasevka";
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp pragmasevka/*.ttf $out/share/fonts/truetype/
        '';
        meta.description = "Pragmasevka Nerd Font (PragmataPro doppelgänger from Iosevka)";
      };
    })
    (
      final: prev:
      let
        patched-catppuccin = prev.python313.pkgs.catppuccin.overrideAttrs (old: {
          doCheck = false;
          pytestCheckPhase = "true";
          pythonImportsCheckPhase = "true";
        });
        custom-python3 = prev.python313.withPackages (ps: [ patched-catppuccin ]);
      in
      {
        python3Packages = prev.python3Packages // {
          catppuccin = patched-catppuccin;
        };
        catppuccin-gtk = prev.catppuccin-gtk.overrideAttrs (old: {
          nativeBuildInputs = [
            prev.gtk3
            prev.sassc
            prev.git
            custom-python3
          ];
        });
      }
    )
    (
      final: prev:
      let
        warpSrc = final.fetchurl {
          url = "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_2026.6.822.0_amd64.deb";
          hash = "sha256-xl9r4/UBGwMLkhtBwTs4ZDlamgwdXm3Oyr3J3O6uYV0=";
        };
        newCloudflareWarp = prev.cloudflare-warp.overrideAttrs (old: {
          version = "2026.6.822.0";
          src = warpSrc;
          buildInputs = (old.buildInputs or [ ]) ++ [
            final.tpm2-tss
            final.curl
            final.libsoup_3
            final.libayatana-appindicator
            final.ayatana-ido
            final.libdbusmenu-gtk3
            final.webkitgtk_4_1
          ];
          autoPatchelfIgnoreMissingDeps = (old.autoPatchelfIgnoreMissingDeps or [ ]) ++ [
            "libjvm.so"
          ];
        });
      in
      {
        cloudflare-warp = newCloudflareWarp;
        cloudflare-warp-headless = prev.cloudflare-warp-headless.overrideAttrs (old: {
          version = "2026.6.822.0";
          src = warpSrc;
          buildInputs = (old.buildInputs or [ ]) ++ [
            final.tpm2-tss
            final.curl
          ];
          autoPatchelfIgnoreMissingDeps = (old.autoPatchelfIgnoreMissingDeps or [ ]) ++ [
            "libayatana-appindicator3.so.1"
            "libayatana-indicator3.so.7"
            "libayatana-ido3-0.4.so.0"
            "libdbusmenu-glib.so.4"
            "libwebkit2gtk-4.1.so.0"
            "libjavascriptcoregtk-4.1.so.0"
            "libsoup-3.0.so.0"
            "libjvm.so"
          ];
        });
      }
    )
  ];
}
