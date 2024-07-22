{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    openconnect-overlay.url = "github:vlaci/openconnect-sso";
    nixos-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    rook-row.url = "git+file:///etc/rook-row";
    operator-mono-font.url = "git+file:///etc/operator-mono";
  };

  outputs = { self, nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.openconnect-overlay.overlay
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      other-nixpkgs = system: {
        unstable = import inputs.unstable (other-nixpkgs-args system);
        nixos-23-11 = import inputs.nixos-23-11 (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) unstable nixos-23-11;
        inherit (inputs) rook-row operator-mono-font;
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
        ];
      };
    };
}
