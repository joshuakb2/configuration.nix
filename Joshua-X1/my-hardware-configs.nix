{ pkgs, config, lib, ... }:
{
  networking.hostName = "Joshua-X1";
  nvidiaTweaks = false;
  useGrub = true;
  josh.operator-mono.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  josh.username = "joshua";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker" "wwwrun" "wireshark" "avahi"];
    description = "Joshua Baker";
    packages = with pkgs; [
      prismlauncher
      protonvpn-cli
      qbittorrent
    ];
  };

  networking.hosts."192.168.1.250" = [ "Joshua-PC" ];

  nmconnections = [ "5207" "Joshua" ];

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];

  services.logind.lidSwitchExternalPower = "ignore";

  environment.systemPackages = with pkgs; [
    retroarch
  ];

  services.avahi.enable = true;
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

  services.httpd = {
    enable = true;
    virtualHosts.http = {
      documentRoot = "/var/www/html";
      listen = [
        {
          port = 80;
          ip = "127.0.0.1";
        }
      ];
    };
  };

  specialisation.No-Funny-Business.configuration = {
    useWayland = lib.mkForce false;
    useGnome = lib.mkForce true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
