{ unstable, nixos-23-11, rook-row, operator-mono-font }: let
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

    google-chrome = unstable.google-chrome.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=VaapiVideoDecoder"
        "--use-gl=egl"
      ];
    };

    hyprpicker = prev.hyprpicker.overrideAttrs (finalH: prevH: rec {
      version = "2ef703474fb96e97e03e66e8820f213359f29382";
      src = prev.fetchFromGitHub {
        owner = "hyprwm";
        repo = prevH.pname;
        rev = version;
        hash = "sha256-MHhAk74uk0qHVwSkLCcXLXMe4478M2oZEFPXwjSoo2E=";
      };
    });

    inherit rook-row;
    inherit operator-mono-font;

    spotify = prev.writeShellApplication {
      name = "spotify";
      text = ''
        ${prev.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
      '';
    };

    # GPU on Wayland on NVIDIA flickers like crazy
    discord-without-gpu = prev.discord.overrideAttrs {
      postInstall = ''
        mv $out/bin/discord $out/bin/discord-original
        makeWrapper $out/bin/discord-original $out/bin/discord --add-flags --disable-gpu
      '';
    };

    # GPU on Wayland on NVIDIA flickers like crazy
    vesktop-without-gpu = prev.vesktop.overrideAttrs {
      postInstall = ''
        mv $out/bin/vesktop $out/bin/vesktop-original
        makeWrapper $out/bin/vesktop-original $out/bin/vesktop --add-flags --disable-gpu
      '';
    };

    android-studio = unstable.android-studio;
    signal-desktop = unstable.signal-desktop;
    swaylock = unstable.swaylock;
    kitty = unstable.kitty;

    # If ssh is not found during build, CVS defaults to RSH instead!!! D:
    cvs = prev.cvs.overrideAttrs {
      buildInputs = [final.openssh];
    };

    keepass = prev.keepass.override {
      plugins = with final; [keepass-keetheme];
    };
    keepass-keetheme = import ./keetheme.nix {
      inherit (final) lib stdenv buildEnv fetchurl mono;
    };
  };
in { nixpkgs.overlays = [myOverlay]; }
