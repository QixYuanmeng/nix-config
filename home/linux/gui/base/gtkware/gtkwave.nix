{
  fetchFromGitHub,
  glib,
  gperf,
  gtk4,
  gtk3,
  gtk-mac-integration,
  judy,
  lib,
  pkg-config,
  stdenv,
  meson,
  ninja,
  flex,
  gobject-introspection,
  desktop-file-utils,
  shared-mime-info,
}:
stdenv.mkDerivation {
  pname = "gtkwave";
  version = "latest";

  src = fetchFromGitHub {
    owner = "gtkwave";
    repo = "gtkwave";
    rev = "491f24d7e8619cfc1fcc65704ee5c967d1083c18";
    sha256 = "sha256-ixXBBAfudX3dnaKQILLgIr6tLDGmOyduHAhX2n5H20I=";
  };

  buildInputs =
    [
      flex
      ninja
      pkg-config
      gtk4
      glib
      gperf
      gobject-introspection
      desktop-file-utils
      shared-mime-info
      gtk3
    ]
    ++ lib.optional stdenv.isDarwin gtk-mac-integration;

  configurePhase = ''
    meson setup build --prefix=$out
  '';

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildPhase = ''
    meson compile -C build
  '';

  installPhase = ''
    meson install -C build
  '';

  meta = {
    description = "VCD/Waveform viewer for Unix and Win32";
    homepage = "https://gtkwave.github.io/gtkwave";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}