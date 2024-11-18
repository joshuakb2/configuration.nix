{ lib, stdenv, buildEnv, fetchurl, mono }:

let
  version = "0.10.7";

  drv = stdenv.mkDerivation {
    pname = "keepass-keetheme";
    inherit version;

    src = fetchurl {
      url = "https://github.com/xatupal/KeeTheme/releases/download/v${version}/KeeTheme.plgx";
      sha256 = "sha256-SxMai1jwydyiWf+RXmN0BxUcz8Oft/pPyc8HfcnF/5Y=";
    };

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    meta = with lib; {
      description = "Enables changing KeePass's appearance.";
      homepage = "https://github.com/xatupal/KeeTheme";
      platforms = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
      license = licenses.mit;
    };
  };
in
  buildEnv { name = drv.name; paths = [mono drv]; }
