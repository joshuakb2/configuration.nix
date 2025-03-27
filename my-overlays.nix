{ lib, nixpkgs-latest, nixpkgs-gnome-beta, rook-row, operator-mono-font, hyprland, system }: let
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

    # Newest dunst has support for hot-reloading config
    dunst = prev.dunst.overrideAttrs {
      version = "4c977cc2f15ee07ede0e342e08228de14aef3771";
      src = final.fetchFromGitHub {
        owner = "dunst-project";
        repo = "dunst";
        rev = "4c977cc2f15ee07ede0e342e08228de14aef3771";
        hash = "sha256-0UadD4CTfm15lhEBd+SFRkK4OHHCi+ljTUVxCaX3qfU=";
      };
      postInstall = ''
        wrapProgram $out/bin/dunst \
          --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"

        wrapProgram $out/bin/dunstctl \
          --prefix PATH : "${lib.makeBinPath [ final.coreutils final.dbus ]}"
      '';
    };

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

    gnomeExtensions = nixpkgs-gnome-beta.gnomeExtensions // {
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

    expressvpn = final.callPackage (import ./custom-packages/expressvpn.nix) {};
    hyprlauncher = final.callPackage (import ./custom-packages/hyprlauncher.nix) {};
    vulkan-hdr-layer = final.callPackage (import ./custom-packages/vulkan-hdr-layer.nix) {};

    kdePackages = nixpkgs-latest.kdePackages;
    yt-dlp = nixpkgs-latest.yt-dlp;
    plex = nixpkgs-latest.plex;
    zoom-us = nixpkgs-latest.zoom-us;

    inherit hyprland;

    # Defined here instead of flake.nix because not all my hosts can fetch this path!
    joshua_bakers_qa_scripts = (builtins.getFlake "git+ssh://git@git.eng.enseo.com/srv/git/joshua_bakers_qa_scripts.git?rev=3274164a40a1ba7bc212231ba8c3513719023fc2").packages.${system};
  };
in {
  nixpkgs.overlays = [myOverlay];
}
