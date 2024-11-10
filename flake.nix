{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2024-july.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    openconnect-overlay.url = "github:vlaci/openconnect-sso";
    rook-row.url = "github:joshuakb2/rook-row";
    operator-mono-font.url = "git+ssh://git@github.com/joshuakb2/operator-mono.git";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland stuff
    aquamarine = {
      type = "git";
      url = "https://github.com/hyprwm/aquamarine";
      ref = "refs/tags/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs-2024-july";
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/hyprland";
      ref = "refs/tags/v0.43.0";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.aquamarine.follows = "aquamarine";
    };

    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.openconnect-overlay.overlay
          nixpkgs-2024-july-overlay
          hyprlandOverlay
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      other-nixpkgs = system: {
        nixpkgs-2024-july = import inputs.nixpkgs-2024-july (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) nixpkgs-2024-july;
        inherit (inputs) rook-row operator-mono-font;
        inherit (nixpkgs) lib;
      };
      nixpkgs-2024-july-overlay = final: prev: {
        nixpkgs-2024-july = import inputs.nixpkgs-2024-july {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };
      hyprlandOverlay = final: prev: {
        hyprland = let
          libinput = prev.libinput.overrideAttrs (self: {
            name = "libinput";
            version = "1.26.0";
            src = final.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "libinput";
              repo = "libinput";
              rev = self.version;
              hash = "sha256-mlxw4OUjaAdgRLFfPKMZDMOWosW9yKAkzDccwuLGCwQ=";
            };
          });
        in
          inputs.hyprland.packages.${prev.system}.hyprland.override {
            libinput = libinput;
            aquamarine = inputs.hyprland.inputs.aquamarine.packages.${prev.system}.aquamarine.override {
              libinput = libinput;
            };
            # need this to fix meson build for some reason?
            wayland-scanner = final.nixpkgs-2024-july.wayland-scanner;
          };
       };
    in {
      nixosConfigurations.Joshua-PC-Nix = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (my-overlays system)
          ./Joshua-PC-Nix/my-hardware-configs.nix
          ./Joshua-PC-Nix/hardware-configuration.nix
          flake-overlays
          ./configuration.nix
        ];
      };

      nixosConfigurations.Joshua-X1 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (my-overlays system)
          ./Joshua-X1/my-hardware-configs.nix
          ./Joshua-X1/hardware-configuration.nix
          flake-overlays
          ./configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.joshua = import ./Joshua-X1/home.nix inputs;
          }
        ];
      };

      nixosConfigurations.JBaker-LT = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (my-overlays system)
          ./JBaker-LT/my-hardware-configs.nix
          ./JBaker-LT/hardware-configuration.nix
          flake-overlays
          ./configuration.nix
        ];
      };
    };
}
