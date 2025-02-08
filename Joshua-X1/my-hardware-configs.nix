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
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker" "wwwrun" "wireshark" "avahi"];
    description = "Joshua Baker";
    packages = with pkgs; [
      expressvpn
      qbittorrent
    ];
  };

  environment.systemPackages = with pkgs; [
    retroarch
  ];

  services.avahi.enable = true;
  services.expressvpn.enable = true;
  programs.steam.enable = true;

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

  virtualisation.docker.daemon.settings = {
    data-root = "/docker";
  };

  specialisation.No-Funny-Business.configuration = {
    useWayland = lib.mkForce false;
    useGnome = lib.mkForce true;
  };
}
