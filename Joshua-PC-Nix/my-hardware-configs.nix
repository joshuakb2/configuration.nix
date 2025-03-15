{ pkgs, config, lib, ... }:

let
  ntfs = device: {
    inherit device;
    fsType = "ntfs";
    options = [
      "defaults"
      "umask=000"
      "dmask=000"
      "fmask=000"
      "windows_names"
    ];
  };

in {
  networking.hostName = "Joshua-PC-Nix";
  nvidiaTweaks = true;
  useGrub = true;
  usePlasma = false;
  josh.operator-mono.enable = true;
  josh.rook-row.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  josh.username = "joshua";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker" "wireshark"];
    description = "Joshua Baker";
    packages = with pkgs; [
      arduino
      expressvpn
      makemkv
      obs-studio
      prismlauncher
      qbittorrent
      qbittorrent-nox
    ];
  };

  # Disable GDM auto-suspend which broadcasts terminal messages and messes with services while I'm using the machine remotely!!!
  services.xserver.displayManager.gdm.autoSuspend = false;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpeg
    gamescope
    retroarch
  ];

  # Necessary for makemkv to find optical drives
  boot.kernelModules = ["sg"];

  boot.supportedFilesystems = ["ntfs"];

  fileSystems."/torrents" = ntfs "/dev/disk/by-uuid/FE421851421810CF";
  fileSystems."/windows" = ntfs "/dev/disk/by-uuid/AE6A5CC36A5C8A4B";
  fileSystems."/games" = ntfs "/dev/disk/by-uuid/70125600261870C2";
  fileSystems."/why-not-more" = ntfs "/dev/disk/by-uuid/CCC6C319C6C30326";

  bindMounts = [
    # Wine requires symlinks, but NTFS doesn't do symlinks.
    {
      src = "/home/joshua/steam_compatdata";
      at = "/games/SteamLibrary/steamapps/compatdata";
    }
  ];

  services.httpd = {
    enable = true;
    virtualHosts.http = {
      documentRoot = "/var/www/html";
      listen = [{ port = 80; }];
    };
    virtualHosts.https = {
      documentRoot = "/var/www/html";
      listen = [{ port = 443; ssl = true; }];
      sslServerCert = "/etc/ssl/certs/apache-selfsigned.crt";
      sslServerKey = "/etc/ssl/private/apache-selfsigned.key";
    };
    extraConfig = ''
      Header Set Access-Control-Allow-Origin *
      Header Set Access-Control-Allow-Headers *
      Header Set Access-Control-Allow-Methods *
    '';
  };

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
  age.secrets.ddns-updater-config = {
    file = ../secrets/ddns-updater-config-Joshua-PC.age;
  };

  services.ddns-updater.enable = true;
  services.ddns-updater.environment = {
    CONFIG_FILEPATH = "%d/config"; # %d goes to $CREDENTIALS_DIRECTORY
  };
  systemd.services.ddns-updater.serviceConfig = {
    LoadCredential = "config:${config.age.secrets.ddns-updater-config.path}";
  };

  services.plex.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
