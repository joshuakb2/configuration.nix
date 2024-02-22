# This was my attempt at getting hypridle available on my system.
# There's an unmerged pull request on github and I basically copied the derivations from it.
# See https://github.com/NixOS/nixpkgs/pull/289630
# hyprlang refuses to build, and I don't understand cmake!!! :'(

{ pkgs, ... }:
let
  hypridleOverlay = final: prev: {
    hypridle = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "hypridle";
      version = "0.1.0";
    
      src = pkgs.fetchFromGitHub {
        owner = "hyprwm";
        repo = "hypridle";
        rev = "v${finalAttrs.version}";
        hash = "sha256-0x5R6v82nKBualYf+TxAduMsvG80EZAl7gofTIYtpf4=";
      };
    
      nativeBuildInputs = with pkgs; [
        cmake
        pkg-config
      ];
    
      buildInputs = with pkgs; [
        hyprlang
        sdbus-cpp
        systemd
        wayland
        wayland-protocols
      ];
    
      meta = with pkgs; {
        description = "Hyprland's idle daemon";
        homepage = "https://github.com/hyprwm/hypridle";
        license = lib.licenses.bsd3;
        maintainers = with lib.maintainers; [ iogamaster ];
        mainProgram = "hypridle";
        inherit (wayland.meta) platforms;
      };
    });

    hyprlang = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "hyprlang";
      version = "0.4.0";
    
      src = pkgs.fetchFromGitHub {
        owner = "hyprwm";
        repo = "hyprlang";
        rev = "v${finalAttrs.version}";
        hash = "sha256-nW3Zrhh9RJcMTvOcXAaKADnJM/g6tDf3121lJtTHnYo=";
      };
    
      nativeBuildInputs = with pkgs; [cmake];
      outputs = ["out" "dev"];
      doCheck = true;
    
      meta = with pkgs; {
        description = "The official implementation library for the hypr config language";
        homepage = "https://github.com/hyprwm/hyprlang";
        license = lib.licenses.gpl3Plus;
        maintainers = with lib.maintainers; [iogamaster];
      };
    });
  };

in { nixpkgs.overlays = [hypridleOverlay]; }
