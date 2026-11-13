{ config, ... }:

{
  imports = [
    ./my-hardware-configs.nix
    ./hardware-configuration.nix
  ];

  home-manager.users.${config.josh.username} = import ./home.nix;
}
