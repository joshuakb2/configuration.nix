{
  description = "Flake for Joshua Baker's devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # last commit of nixos-unstable before the Linux 6.19 kernel went EOL.
    nixpkgs-life-support.url = "github:NixOS/nixpkgs/162f04bf3dd222187388bc990a8678170d594419";
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    home-manager-life-support = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-life-support";
    };
    agenix.url = "github:ryantm/agenix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fingerprint-sensor.url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
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
        inherit (other-nixpkgs system) nixpkgs-latest nixpkgs-25-11;
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

      hostConfigs = {
        Joshua-PC-Nix = {
          system = "x86_64-linux";
          configPath = ./Joshua-PC-Nix;
          nixpkgs = nixpkgs;
          home-manager = inputs.home-manager;
        };

        Joshua-X1 = {
          system = "x86_64-linux";
          configPath = ./Joshua-X1;
          nixpkgs = nixpkgs;
          home-manager = inputs.home-manager;
        };

        JBaker-Area51 = {
          system = "x86_64-linux";
          configPath = ./JBaker-Area51;
          nixpkgs = inputs.nixpkgs-life-support;
          home-manager = inputs.home-manager-life-support;
        };

        JBaker-Thinkpad = {
          system = "x86_64-linux";
          configPath = ./JBaker-Thinkpad;
          nixpkgs = nixpkgs;
          home-manager = inputs.home-manager;
        };
      };

      nixosConfigurationFor = { host, extraModules ? [] }:
        let inherit (hostConfigs.${host}) system configPath nixpkgs home-manager;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (my-overlays system)
            flake-overlays
            homeManagerCommonSetup
            inputs.agenix.nixosModules.default # Provides config.age and supports secret decryption
            inputs.lanzaboote.nixosModules.lanzaboote # Secure Boot support
            (agenixModule system) # Adds agenix binary to environment for encrypting new secrets
            home-manager.nixosModules.home-manager
            ./configuration.nix
            configPath
          ] ++ extraModules;
        };
    in {
      nixosConfigurations.Joshua-PC-Nix = nixosConfigurationFor {
        host = "Joshua-PC-Nix";
        extraModules = [
          inputs.qbittorrent-protonvpn-docker.nixosModules.default
        ];
      };

      nixosConfigurations.Joshua-X1 = nixosConfigurationFor {
        host = "Joshua-X1";
        extraModules = [
          inputs.fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
          {
            services."06cb-009a-fingerprint-sensor" = {
              enable = true;
              backend = "libfprint-tod";
              calib-data-file = ./calib-data.bin;
            };
          }
        ];
      };

      nixosConfigurations.JBaker-Area51 = nixosConfigurationFor { host = "JBaker-Area51"; };

      nixosConfigurations.JBaker-Thinkpad = nixosConfigurationFor { host = "JBaker-Thinkpad"; };
    };
}
