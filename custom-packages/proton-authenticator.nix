{
  autoPatchelfHook,
  cairo,
  dpkg,
  fetchurl,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  libsoup_3,
  makeWrapper,
  pango,
  stdenv,
  webkitgtk_4_1,
  wrapGAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "proton-authenticator";
  version = "1.0.0";

  src = fetchurl {
    url = "https://proton.me/download/authenticator/linux/ProtonAuthenticator_${finalAttrs.version}_amd64.deb";
    hash = finalAttrs.srcHash or "sha256-Ri6U7tuQa5nde4vjagQKffWgGXbZtANNmeph1X6PFuM=";
  };

  unpackPhase = "dpkg-deb -x $src unpack";

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    glib
    makeWrapper
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    glib-networking
    cairo
    pango
    libsoup_3
    gdk-pixbuf
    gtk3
    webkitgtk_4_1
  ];

  installPhase = ''
    mv unpack/usr $out
    wrapProgram $out/bin/proton-authenticator \
      --set __NV_DISABLE_EXPLICIT_SYNC 1
  '';
})
