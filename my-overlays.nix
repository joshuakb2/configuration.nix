let
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

    google-chrome = final.unstable.google-chrome.override {
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

    rook-row = import ../rook-row final;
    operator-mono-font = import ../operator-mono final;
    kpuinput = import ../kpuinput final;

    spotify = prev.writeShellApplication {
      name = "spotify";
      text = ''
        ${prev.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
      '';
    };

    discord = final.writeShellScriptBin "discord" ''
      # GPU on Wayland on NVIDIA flickers like crazy
      exec ${prev.discord}/bin/discord --disable-gpu
    '';

    nixos23-11 = import <nixos-23-11> { config = { allowUnfree = true; }; };
    unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
    swaylock = final.unstable.swaylock;
  };
in { nixpkgs.overlays = [myOverlay]; }
