{
  dpkg,
  makeWrapper,
  python3,
  python3Packages,
  stdenv,
  zenity,
}:

stdenv.mkDerivation {
  pname = "stb-qa-toolbox";
  version = "0.0.8";

  src = ../stb-qa-toolbox_0.0.8_all.deb;

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];
  buildInputs = [
    python3Packages.tkinter
    zenity
  ];

  unpackPhase = "dpkg-deb -x $src unpack";
  patchPhase = ''
    mv unpack/usr/local unpack/local
    mv unpack/local/bin unpack/usr/bin
    rmdir unpack/local
    sed -i 's,#!/bin/bash,#!${stdenv.shell},' unpack/usr/bin/stb-qa-toolbox
    sed -i 's,cd /usr/local/bin,cd "$(dirname "$0")",' unpack/usr/bin/stb-qa-toolbox
    sed -i 's,/usr/local/bin/stb-qa-toolbox,stb-qa-toolbox,' unpack/usr/share/applications/stb-qa-toolbox.desktop
  '';
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    cp -r unpack/usr $out
  '';
  fixupPhase = ''
    wrapProgram $out/bin/stb-qa-toolbox \
      --prefix PATH : ${python3}/bin \
      --prefix PYTHONPATH : ${python3Packages.tkinter}/${python3.sitePackages}
  '';
}
