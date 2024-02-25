{ pkgs, ... }:
let
  updateSystemdResolvedRepo = pkgs.fetchFromGitHub {
    owner = "jonathanio";
    repo = "update-systemd-resolved";
    rev = "v1.3.0";
    sha256 = "sha256-lYJTR3oBmpENcqNHa9PFXsw7ly6agwjBWf4UXf1d8Kc=";
  };

  myOverlay = final: prev: {
    openvpn-update-systemd-resolved = pkgs.writeShellApplication {
      name = "update-systemd-resolved";
      runtimeInputs = with pkgs; [bash iproute2 logger coreutils systemd];
      text = "${updateSystemdResolvedRepo}/update-systemd-resolved \"$@\"";
    };

    hyprpicker = prev.hyprpicker.overrideAttrs (final: prev: rec {
      version = "2ef703474fb96e97e03e66e8820f213359f29382";
      src = pkgs.fetchFromGitHub {
        owner = "hyprwm";
        repo = prev.pname;
        rev = version;
        hash = "sha256-MHhAk74uk0qHVwSkLCcXLXMe4478M2oZEFPXwjSoo2E=";
      };
    });
  };
in { nixpkgs.overlays = [myOverlay]; }
