[
  # Everything in ./pkgs becomes pkgs.<name>.
  (
    final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./pkgs;
    }
  )

  # catppuccin-gtk's python deps fail their own tests.
  (
    final: prev:
    let
      catppuccin = prev.python313.pkgs.catppuccin.overrideAttrs {
        doCheck = false;
        pytestCheckPhase = "true";
        pythonImportsCheckPhase = "true";
      };
    in
    {
      python3Packages = prev.python3Packages // {
        inherit catppuccin;
      };
      catppuccin-gtk = prev.catppuccin-gtk.overrideAttrs {
        nativeBuildInputs = [
          prev.gtk3
          prev.sassc
          prev.git
          (prev.python313.withPackages (_: [ catppuccin ]))
        ];
      };
    }
  )

  (final: prev: {
    cpplint = prev.cpplint.overridePythonAttrs {
      doCheck = false;
      doInstallCheck = false;
    };

    # Ship the Cyborg 15 fan profile with nbfc.
    nbfc-linux = prev.nbfc-linux.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        install -Dm644 ${./dotfiles/nbfc/cyborg-15-a12udx.json} \
          "$out/share/nbfc/configs/Cyborg 15 A12UDX.json"
      '';
    });
  })

  # Cloudflare WARP newer than nixpkgs.
  (
    final: prev:
    let
      version = "2026.6.822.0";
      src = final.fetchurl {
        url = "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_${version}_amd64.deb";
        hash = "sha256-xl9r4/UBGwMLkhtBwTs4ZDlamgwdXm3Oyr3J3O6uYV0=";
      };
    in
    {
      cloudflare-warp = prev.cloudflare-warp.overrideAttrs (old: {
        inherit version src;
        buildInputs = (old.buildInputs or [ ]) ++ [
          final.tpm2-tss
          final.curl
          final.libsoup_3
          final.libayatana-appindicator
          final.ayatana-ido
          final.libdbusmenu-gtk3
          final.webkitgtk_4_1
        ];
        autoPatchelfIgnoreMissingDeps = (old.autoPatchelfIgnoreMissingDeps or [ ]) ++ [ "libjvm.so" ];
      });

      cloudflare-warp-headless = prev.cloudflare-warp-headless.overrideAttrs (old: {
        inherit version src;
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
]
