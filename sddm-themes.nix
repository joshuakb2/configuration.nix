{ config, pkgs, lib, ... }:
let
  mkSddmTheme = { name, version, github ? null, zip ? null }:
    {
      name = "sddm-theme-${name}";
      value = pkgs.stdenv.mkDerivation (rec {
        inherit version;
        pname = "sddm-theme-${name}";
        dontBuild = true;
        src =
          if zip != null
          then pkgs.fetchzip {
            inherit (zip) url sha256;
          }
          else if github != null
          then pkgs.fetchFromGitHub {
            inherit (github) owner repo sha256;
            rev = version;
          }
          else abort "You must provide either \"zip\" or \"github\".";
        installPhase = ''
          mkdir -p $out/share/sddm/themes
          cp -aR $src $out/share/sddm/themes/${name}
        '';
        nativeBuildInputs = [pkgs.libsForQt5.qt5.wrapQtAppsHook];
        propagatedUserEnvPkgs = [pkgs.libsForQt5.qt5.qtgraphicaleffects];
      });
    };

  mkSddmThemes = list: builtins.listToAttrs (builtins.map mkSddmTheme list);
in
{
  # Include the indicated theme in the list of packages to be installed in the system.
  # services.xserver.displayManager.sddm.theme should be a string matching the name of
  # one of the themes listed below.
  environment.systemPackages = [
    pkgs."sddm-theme-${config.services.xserver.displayManager.sddm.theme}"
  ];

  nixpkgs.overlays = [(final: prev:
    mkSddmThemes [
      {
        name = "sugar-candy";
        version = "1.1";
        zip = {
          url = "https://framagit.org/MarianArlt/sddm-sugar-candy/-/archive/v.1.1/sddm-sugar-candy-v.1.1.zip";
          sha256 = "sha256-HgUoVMaOZ4wdiP9MTvXhI5o3ItQUoXX/NtnokR42A9c=";
        };
      }
      {
        name = "sugar-dark";
        version = "v1.2";
        github = {
          owner = "MarianArlt";
          repo = "sddm-sugar-dark";
          sha256 = "0gx0am7vq1ywaw2rm1p015x90b75ccqxnb1sz3wy8yjl27v82yhb";
        };
      }
      {
        name = "chili";
        version = "0.1.5";
        github = {
          owner = "MarianArlt";
          repo = "sddm-chili";
          sha256 = "sha256-wxWsdRGC59YzDcSopDRzxg8TfjjmA3LHrdWjepTuzgw=";
        };
      }
    ]
  )];
}
