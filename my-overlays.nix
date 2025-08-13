{ lib, nixpkgs, nixpkgs-latest, rook-row, operator-mono-font, hyprland, system }: let
  updateSystemdResolvedRepo = pkgs: pkgs.fetchFromGitHub {
    owner = "jonathanio";
    repo = "update-systemd-resolved";
    rev = "v1.3.0";
    sha256 = "sha256-lYJTR3oBmpENcqNHa9PFXsw7ly6agwjBWf4UXf1d8Kc=";
  };

  myOverlay = final: prev: {
    openvpn-update-systemd-resolved = prev.writeShellApplication {
      name = "update-systemd-resolved";
      runtimeInputs = with final; [bash iproute2 logger coreutils systemd];
      text = "${updateSystemdResolvedRepo prev}/update-systemd-resolved \"$@\"";
    };

    inherit rook-row;
    inherit operator-mono-font;

    spotify = prev.writeShellApplication {
      name = "spotify";
      text = ''
        ${prev.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
      '';
    };

    slack = prev.slack.overrideAttrs (prevAttrs: {
      installPhase =
        prevAttrs.installPhase + ''
          sed -i.backup -e 's/WebRTCPipeWireCapturer/LebRTCPipeWireCapturer/' $out/lib/slack/resources/app.asar
        '';
    });

    # If ssh is not found during build, CVS defaults to RSH instead!!! D:
    cvs = prev.cvs.overrideAttrs {
      buildInputs = [final.openssh];
    };

    keepass = prev.keepass.override {
      plugins = with final; [keepass-keetheme];
    };
    keepass-keetheme = import ./custom-packages/keetheme.nix {
      inherit (final) lib stdenv buildEnv fetchurl mono;
    };

    make-it-so = final.writeShellScriptBin "make-it-so" ''
      if (( $# == 0 )); then
        sudo nixos-rebuild switch
      else
        sudo nixos-rebuild "$@"
      fi
    '';

    gnomeExtensions = prev.gnomeExtensions // {
      multi-monitor-login = final.callPackage (import ./custom-packages/gdm-multi-monitor-login.nix) {};
    };

    ddns-updater = prev.ddns-updater.overrideAttrs {
      src = final.fetchFromGitHub {
        owner = "joshuakb2";
        repo = "ddns-updater";
        rev = "85ce8f5f4c3e6e85581185f35c72db18e58f4856";
        hash = "sha256-2zu2DbIgFdkDiLJIXM6ERDuwQHZNX0u+bbb95l5AzBw=";
      };
    };

    retroarch = prev.wrapRetroArch {
      cores = with final.libretro; [
        quicknes
      ];
    };

    hyprlauncher = final.callPackage (import ./custom-packages/hyprlauncher.nix) {};
    proton-authenticator = final.callPackage (import ./custom-packages/proton-authenticator.nix) {};
    vulkan-hdr-layer = final.callPackage (import ./custom-packages/vulkan-hdr-layer.nix) {};

    # Please fetch these, don't rebuild them!
    obs-studio = nixpkgs.obs-studio;
    wireshark = nixpkgs.wireshark;
    electron = nixpkgs.electron;
    libreoffice = nixpkgs.libreoffice;
    vesktop = nixpkgs.vesktop;
    teams-for-linux = nixpkgs.teams-for-linux;
    evolution-data-server = nixpkgs.evolution-data-server;

    # Always update these!!!
    kdePackages = nixpkgs-latest.kdePackages;
    yt-dlp = nixpkgs-latest.yt-dlp;
    plex = nixpkgs-latest.plex.override {
      plexRaw = nixpkgs-latest.plexRaw.overrideAttrs rec {
        version = "1.42.1.10054-f333bdaa8";
        src = nixpkgs-latest.fetchurl {
          url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
          sha256 = "sha256-ml2d029Zu2OnD5DOK0bDVzacfa6RU+e1V4KoK1IR9oA=";
        };
      };
    };
    signal-desktop = nixpkgs-latest.signal-desktop;
    vimPlugins = nixpkgs-latest.vimPlugins;
    zoom-us = nixpkgs-latest.zoom-us;
    docker = nixpkgs-latest.docker;

    inherit hyprland;

    # Defined here instead of flake.nix because not all my hosts can fetch this path!
    joshua_bakers_qa_scripts = (builtins.getFlake "git+ssh://git@git.eng.enseo.com/srv/git/joshua_bakers_qa_scripts.git?rev=8a1d64095238d0c28731555c7c02967e6d5683be").packages.${system};
  };
in {
  nixpkgs.overlays = [myOverlay];
}
