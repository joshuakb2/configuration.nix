{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    openconnect-overlay.url = "github:vlaci/openconnect-sso";
    operator-mono-font.url = "git+ssh://git@github.com/joshuakb2/operator-mono.git";
    qbittorrent-protonvpn-docker = {
      url = "github:joshuakb2/qbittorrent-protonvpn-docker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland/v0.50.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ...}@inputs:
    let
      flake-overlays = {
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.openconnect-overlay.overlay
        ];
      };
      other-nixpkgs-args = system: {
        inherit system;
        config.allowUnfree = true;
      };
      other-nixpkgs = system: {
        nixpkgs-latest = import inputs.nixpkgs-latest (other-nixpkgs-args system);
        nixpkgs = import nixpkgs (other-nixpkgs-args system);
      };
      my-overlays = system: import ./my-overlays.nix {
        inherit (other-nixpkgs system) nixpkgs-latest nixpkgs;
        inherit (inputs) operator-mono-font;
        inherit (nixpkgs) lib;
        inherit system;
        hyprland = inputs.hyprland.packages.${system}.hyprland;
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

      nixosConfigurations.JBaker-Thinkpad = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = modulesFor system ./JBaker-Thinkpad;
      };
    };
}
