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
    hyprgrass.url = "github:horriblename/hyprgrass";
  };

  outputs = { self, nixpkgs, ...}@inputs:
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
            home-manager.backupFileExtension = "backup";
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
