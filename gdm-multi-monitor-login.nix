{ pkgs, lib, stdenv, fetchFromGitHub, nixosTests }:

let
  uuid = "multi-monitor-login@derflocki.github.com";

in
  stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-multi-monitor-login";
    version = "59a98a1537123841fec5b7d1b5abde975e7b71e7";
    src = fetchFromGitHub {
      owner = "derflocki";
      repo = "multi-monitor-login";
      rev = version;
      hash = "sha256-Xe90nre5Xe9HdcWGMyUa/hfd8Wf7WUUZgfU2STmqLGM=";
    };
    nativeBuildInputs = with pkgs; [buildPackages.glib];
    buildPhase = ''
      runHook preBuild
      if [ -d schemas ]; then
        glib-compile-schemas --strict schemas
      fi
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gnome-shell/extensions/
      cp -r -T . $out/share/gnome-shell/extensions/${uuid}
      runHook postInstall
    '';
    passthru = {
      extensionUuid = uuid;
      tests = {
        gnome-extensions = nixosTests.gnome-extensions;
      };
    };
  }
