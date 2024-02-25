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
  };
in { nixpkgs.overlays = [myOverlay]; }
