{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2024-july.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-gnome-beta.url = "github:NixOS/nixpkgs/gnome";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    openconnect-overlay.url = "github:vlaci/openconnect-sso";
    rook-row.url = "github:joshuakb2/rook-row";
    operator-mono-font.url = "git+ssh://git@github.com/joshuakb2/operator-mono.git";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/hyprland/v0.48.0";
    hyprland-hdr.url = "github:UjinT34/Hyprland/simple-cm";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.openconnect-overlay.overlay
          nixpkgs-2024-july-overlay
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config.allowUnfree = true;
      };
      other-nixpkgs = system: {
        nixpkgs-latest = import inputs.nixpkgs-latest (other-nixpkgs-args system);
        nixpkgs-gnome-beta = import inputs.nixpkgs-gnome-beta (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) nixpkgs-latest nixpkgs-gnome-beta;
        inherit (inputs) rook-row operator-mono-font;
        inherit (nixpkgs) lib;
        hyprland = inputs.hyprland.packages.${system}.hyprland;
        hyprland-hdr = inputs.hyprland-hdr.packages.${system}.hyprland;
      };
      nixpkgs-2024-july-overlay = final: prev: {
        nixpkgs-2024-july = import inputs.nixpkgs-2024-july {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };

      homeManagerCommonSetup = { config, ... }: rec {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = inputs // {
          inherit (home-manager) backupFileExtension;
          inherit (config.josh) username;
        };
      };

      agenixModule = system: {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
        ];
      };

      modulesFor = system: hostConfigPath: [
        ({ utils, config, lib, options, specialArgs, modulesPath }@args:
          let
            gnome = import "${inputs.nixpkgs-gnome-beta}/nixos/modules/services/x11/desktop-managers/gnome.nix";
            pkgs = inputs.nixpkgs-gnome-beta.legacyPackages.${system}.extend (final: pkgs: {
              gnome-user-share = pkgs.gnome-user-share.overrideAttrs (prev: {
                nativeBuildInputs = prev.nativeBuildInputs ++ (with pkgs; [ cargo rustc ]);
              });
            });
            newArgs = args // { inherit pkgs; };
          in gnome newArgs
        )
        (my-overlays system)
        flake-overlays
        homeManagerCommonSetup
        inputs.agenix.nixosModules.default # Provides config.age and supports secret decryption
        (agenixModule system) # Adds agenix binary to environment for encrypting new secrets
        inputs.home-manager.nixosModules.home-manager
        ./configuration.nix
        hostConfigPath
      ];
    in {
      nixosConfigurations.Joshua-PC-Nix = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./Joshua-PC-Nix;
      };

      nixosConfigurations.Joshua-X1 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./Joshua-X1;
      };

      nixosConfigurations.JBaker-LT = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./JBaker-LT;
      };
    };
}
