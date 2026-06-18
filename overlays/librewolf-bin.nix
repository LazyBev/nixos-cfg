final: prev: let
  version = "152.0-1";
in {
  librewolf-unwrapped = prev.stdenv.mkDerivation {
    pname = "librewolf-unwrapped";
    inherit version;

    src = prev.fetchurl {
      url = "https://dl.librewolf.net/librewolf/${version}/librewolf-${version}-linux-x86_64-package.tar.xz";
      sha256 = "b08a720a97e8f62819d0f31dd58eec748a2e8bcf1d0bd0e39708cde4ce472ec4";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ prev.autoPatchelfHook ];

    buildInputs = with prev; [
      alsa-lib
      atk
      cairo
      dbus
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libxi
      libxcb
      libxrandr
      libxrender
      pango
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
    ];

    installPhase = ''
      mkdir -p $out/lib/librewolf $out/bin
      cp -r librewolf/* $out/lib/librewolf/
      ln -s $out/lib/librewolf/librewolf-bin $out/bin/librewolf
    '';

    passthru = {
      gtk3 = prev.gtk3;
      requireSigning = false;
      allowAddonSideload = true;
      applicationName = "LibreWolf";
      binaryName = "librewolf";
      libName = "librewolf";
      ffmpegSupport = false;
      gssSupport = false;
      alsaSupport = true;
      pipewireSupport = false;
      sndioSupport = false;
      jackSupport = false;
    };

    meta = {
      description = "LibreWolf web browser (prebuilt binary)";
      homepage = "https://librewolf.net";
      license = prev.lib.licenses.mpl20;
      platforms = [ "x86_64-linux" ];
    };
  };
}
