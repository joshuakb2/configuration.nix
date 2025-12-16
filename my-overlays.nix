{ lib, nixpkgs, nixpkgs-latest, operator-mono-font, system }: let
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

          # This might prevent Slack from working on X11, but it seems necessary to make it use Wayland for some reason.
          wrapProgram $out/bin/slack \
            --add-flag --ozone-platform=wayland
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
        mgba
        beetle-gba
      ];
    };

    proton-authenticator = final.callPackage (import ./custom-packages/proton-authenticator.nix) {};
    vulkan-hdr-layer = final.callPackage (import ./custom-packages/vulkan-hdr-layer.nix) {};

    stb-qa-toolbox = final.callPackage (import ./custom-packages/stb-qa-toolbox.nix) {};
    obs-studio = nixpkgs.obs-studio.override {
      cudaSupport = true;
    };

    # Please fetch these, don't rebuild them!
    wireshark = nixpkgs.wireshark;
    electron = nixpkgs.electron;
    libreoffice = nixpkgs.libreoffice;
    vesktop = nixpkgs.vesktop;
    teams-for-linux = nixpkgs.teams-for-linux;
    evolution-data-server = nixpkgs.evolution-data-server;

    # Always update these!!!
    kdePackages = nixpkgs-latest.kdePackages;
    yt-dlp = nixpkgs-latest.yt-dlp;
    plex = nixpkgs-latest.plex;
    # # This is how you override the plex version, FYI!
    # plex = nixpkgs-latest.plex.override {
    #   plexRaw = nixpkgs-latest.plexRaw.overrideAttrs rec {
    #     version = "1.42.1.10054-f333bdaa8";
    #     src = nixpkgs-latest.fetchurl {
    #       url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
    #       sha256 = "sha256-ml2d029Zu2OnD5DOK0bDVzacfa6RU+e1V4KoK1IR9oA=";
    #     };
    #   };
    # };

    signal-desktop = nixpkgs-latest.signal-desktop;
    vimPlugins = nixpkgs-latest.vimPlugins;
    zoom-us = nixpkgs-latest.zoom-us;
    docker = nixpkgs-latest.docker;

    # inherit hyprland;

    # Defined here instead of flake.nix because not all my hosts can fetch this path!
    joshua_bakers_qa_scripts = (builtins.getFlake "git+ssh://git@git.eng.enseo.com/srv/git/joshua_bakers_qa_scripts.git?rev=78fe2fd8a648b81e19bba5d61e20524144ba6454").packages.${system};

    waypipe = prev.runCommand "waypipe" {} ''
      mkdir -p $out/etc/bash_completion.d
      for f in ''$(ls -A ${prev.waypipe}/); do
        if [[ $f == etc ]]; then
          for g in ''$(ls -A ${prev.waypipe}/etc/); do
            ln -s ${prev.waypipe}/etc/$g $out/etc/$g
          done
        else
          ln -s ${prev.waypipe}/$f $out/$f
        fi
      done

      cat >$out/etc/bash_completion.d/waypipe <<'EOF'
      _comp_cmd_waypipe() {
        if (( $COMP_CWORD == 1 )); then
          COMPREPLY=($(compgen -W "ssh server client" -- ''${COMP_WORDS[$COMP_CWORD]}));
          return;
        fi;
        if [[ ''${COMP_WORDS[1]} == ssh ]]; then
          _comp_command_offset 1
          return;
        fi;
      }
      complete -F _comp_cmd_waypipe waypipe
      EOF
    '';
  };
in {
  nixpkgs.overlays = [myOverlay];
}
