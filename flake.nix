{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2024-july.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-kde-6-1-0.url = "github:NixOS/nixpkgs/e2a7bc61f2d85fb2f3c45525a29a3bc1511bad5b";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    openconnect-overlay.url = "github:vlaci/openconnect-sso";
    rook-row.url = "github:joshuakb2/rook-row";
    operator-mono-font.url = "git+ssh://git@github.com/joshuakb2/operator-mono.git";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/hyprland";
    # hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.openconnect-overlay.overlay
          nixpkgs-2024-july-overlay
          inputs.hyprland.overlays.default
          # inputs.hyprpicker.overlays.default
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      other-nixpkgs = system: {
        nixpkgs-kde-6-1-0 = import inputs.nixpkgs-kde-6-1-0 (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) nixpkgs-kde-6-1-0;
        inherit (inputs) rook-row operator-mono-font;
        inherit (nixpkgs) lib;
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

      modulesFor = system: hostConfigPath: [
        (my-overlays system)
        flake-overlays
        homeManagerCommonSetup
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
