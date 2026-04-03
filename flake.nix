{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-nvidia-590-fix.url = "github:ccicnce113424/nixpkgs/nvidia-fix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    enseo-vpn.url = "github:joshuakb2/enseo-vpn";
    operator-mono-font.url = "git+ssh://git@github.com/joshuakb2/operator-mono.git";
    qbittorrent-protonvpn-docker = {
      url = "github:joshuakb2/qbittorrent-protonvpn-docker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    # Fixes lanzaboote incompatibility with newer nixpkgs.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config.allowUnfree = true;
      };
      other-nixpkgs = system: {
        nixpkgs-latest = import inputs.nixpkgs-latest (other-nixpkgs-args system);
        nixpkgs = import nixpkgs (other-nixpkgs-args system);
        nixpkgs-25-11 = import inputs.nixpkgs-25-11 (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) nixpkgs-latest nixpkgs nixpkgs-25-11;
        inherit (inputs) operator-mono-font enseo-vpn;
        inherit system;
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

      nvidiaFixModule = system: let pkgs = (import inputs.nixpkgs-nvidia-590-fix { inherit system; config.allowUnfree = true; }); in {
        hardware.nvidia.package = pkgs.lib.mkForce pkgs.linuxPackages_latest.nvidiaPackages.latest;
      };

      modulesFor = system: hostConfigPath: [
        (my-overlays system)
        flake-overlays
        homeManagerCommonSetup
        inputs.agenix.nixosModules.default # Provides config.age and supports secret decryption
        inputs.lanzaboote.nixosModules.lanzaboote # Secure Boot support
        (agenixModule system) # Adds agenix binary to environment for encrypting new secrets
        inputs.home-manager.nixosModules.home-manager
        ./configuration.nix
        hostConfigPath
      ];
    in {
      nixosConfigurations.Joshua-PC-Nix = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./Joshua-PC-Nix ++ [
          inputs.qbittorrent-protonvpn-docker.nixosModules.default
        ];
      };

      nixosConfigurations.Joshua-X1 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./Joshua-X1;
      };

      nixosConfigurations.JBaker-LT = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./JBaker-Area51 ++ [
          (nvidiaFixModule system)
        ];
      };

      nixosConfigurations.JBaker-Thinkpad = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./JBaker-Thinkpad;
      };
    };
}
