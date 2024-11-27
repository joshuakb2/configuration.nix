{ pkgs, config, lib, ... }:
{
  networking.hostName = "Joshua-X1";
  nvidiaTweaks = false;
  useGrub = true;
  josh.operator-mono.enable = true;
  josh.rook-row.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  josh.username = "joshua";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "wwwrun" "wireshark" "avahi"];
    description = "Joshua Baker";
    packages = with pkgs; [
      qbittorrent
    ];
  };

  environment.systemPackages = with pkgs; [
    retroarch
  ];

  programs.steam.enable = true;

  services.avahi.enable = true;

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "pc.joshuabaker.me";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
}
