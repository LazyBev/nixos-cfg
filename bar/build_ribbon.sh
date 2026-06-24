#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
WLR="wlr-layer-shell-unstable-v1"
SRC="src"
CSRC="csrc"

# generate wayland protocol code if missing
if [ ! -f "${CSRC}/${WLR}.c" ]; then
  echo "Generating protocol code..."
  PROTO=$(pkg-config --variable=pkgdatadir wayland-protocols 2>/dev/null || echo "")
  if [ -z "$PROTO" ]; then
    PROTO=$(find /nix/store -maxdepth 4 -name "wayland-protocols" -type d 2>/dev/null | head -1)
  fi

  STABLE="$PROTO/stable"
  STAGING="$PROTO/staging"
  UNSTABLE="$PROTO/unstable"

  XDG_XML=""
  for d in "$STABLE/xdg-shell" "$STAGING/xdg-shell" /usr/share/wayland-protocols/stable/xdg-shell; do
    test -f "$d/xdg-shell.xml" && { XDG_XML="$d/xdg-shell.xml"; break; }
  done
  if [ -z "$XDG_XML" ]; then
    echo "ERROR: cannot find xdg-shell.xml" >&2
    exit 1
  fi

  WLR_XML=""
  for d in "$UNSTABLE/wlr-layer-shell" /usr/share/wayland-protocols/unstable/wlr-layer-shell; do
    test -f "$d/wlr-layer-shell-unstable-v1.xml" && { WLR_XML="$d/wlr-layer-shell-unstable-v1.xml"; break; }
  done
  if [ -z "$WLR_XML" ]; then
    if [ ! -f "wlr-layer-shell-unstable-v1.xml" ]; then
      echo "Downloading wlr-layer-shell-unstable-v1.xml"
      curl -sL "https://raw.githubusercontent.com/swaywm/wlr-protocols/master/unstable/wlr-layer-shell-unstable-v1.xml" -o "wlr-layer-shell-unstable-v1.xml"
    fi
    WLR_XML="wlr-layer-shell-unstable-v1.xml"
  fi

  wayland-scanner client-header "$XDG_XML" "${CSRC}/xdg-shell.h"
  wayland-scanner private-code "$XDG_XML" "${CSRC}/xdg-shell.c"
  wayland-scanner client-header "$WLR_XML" "${CSRC}/${WLR}.h"
  wayland-scanner private-code "$WLR_XML" "${CSRC}/${WLR}.c"
fi

# compile C files to objects
echo "Compiling C objects..."
PKGCONFIG_DIRS=""
for pkg in \
  v3jm5z02mx668hx7gwd9kwxqxpfyd62i-wayland-1.25.0-dev \
  rjadd507fdm0mxb5gy8xbygnszg22mg8-cairo-1.18.4-dev \
  fc49p5f37lazii33yk85dkhn136xnlzz-librsvg-2.62.1-dev \
  q9ksx8c79jfj1cawwwzmpq3qapvpvab7-glib-2.88.1-dev \
  s8666p9giz8ckcvc5jf9nch0cwlybw4n-gdk-pixbuf-2.44.6-dev \
  nz7v24xpw0zrw0k2lq5mql6zvpv9hcif-pango-1.57.1-dev \
  kbhcqcysbclabk7vwmbn2ffi1xnnxbxi-fontconfig-2.17.1-dev \
  xxvp72sjvk902yd2z59gw3fmg6z4rcbm-freetype-2.14.2-dev \
  qd3gla6sn63is90462qdfqwsvppkrhby-libpng-apng-1.6.56-dev \
  aj7zqrfxvg96ldyph7fly6qgprcm2krv-libffi-3.5.2-dev \
  nhl6l0mxarafm0g1mk4yd2xzcws4qz7d-expat-2.8.0-dev \
  0bl6ygm0mvpkvmyqzfynx0czpisxchgz-fribidi-1.0.16-dev \
  fkkiw87rdlmw7dzqbnn908gkzp3ix6md-harfbuzz-13.2.1-dev \
  rlzm88ay9s27biynqbypdsjb64lypacy-libxkbcommon-1.13.1-dev \
  6fbkwxv11i13lsgq8w1lzlaxm4c2a90b-libxcb-1.17.0-dev \
  15h9askp4k1lx44d9871wid23j2a8ijp-glibc-2.42-61-dev \
  d79hb4xkb7xshviv2na82r9min25c83z-libice-1.1.2-dev \
; do
  dir="/nix/store/${pkg}"
  if [ -d "$dir/lib/pkgconfig" ]; then
    PKGCONFIG_DIRS="${PKGCONFIG_DIRS}:${dir}/lib/pkgconfig"
  fi
done
export PKG_CONFIG_PATH="${PKGCONFIG_DIRS#:}"
PKG_CONFIG="${PKG_CONFIG:-/nix/store/1m05k7xgfnw6jc21xxk5681ni3ar97wf-pkg-config-wrapper-0.29.2/bin/pkg-config}"

PKGCFLAGS="$($PKG_CONFIG --cflags wayland-client cairo librsvg-2.0) -I${CSRC}"
PKGLIBS="$($PKG_CONFIG --libs wayland-client cairo librsvg-2.0)"

gcc -c -O2 -Wall $PKGCFLAGS "${CSRC}/render.c" -o build/render.o
gcc -c -O2 -Wall $PKGCFLAGS "${CSRC}/${WLR}.c" -o "build/${WLR}.o"
gcc -c -O2 -Wall $PKGCFLAGS "${CSRC}/xdg-shell.c" -o build/xdg-shell.o

# build Odin binary
echo "Building ribbon..."
odin build "${SRC}" \
  -out:build/ribbon \
  -extra-linker-flags:"$(pwd)/build/wlr-layer-shell-unstable-v1.o $(pwd)/build/xdg-shell.o $PKGLIBS -lrt -lm"

echo "Done: build/ribbon"
