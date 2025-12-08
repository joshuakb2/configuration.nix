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
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "proton-authenticator";
  version = "1.1.4";

  src = fetchurl {
    url = "https://proton.me/download/authenticator/linux/ProtonAuthenticator_${finalAttrs.version}_amd64.deb";
    hash = finalAttrs.srcHash or "sha256-SoTeqnYDMgCoWLGaQZXaHiRKGreFn7FPSz5C0O88uWM=";
  };

  unpackPhase = "dpkg-deb -x $src unpack";

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    glib
    makeWrapper
    wrapGAppsHook3
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
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';
})
