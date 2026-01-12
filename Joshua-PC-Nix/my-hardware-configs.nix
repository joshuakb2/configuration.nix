{
  pkgs,
  config,
  lib,
  ...
}:

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

in
{
  networking.hostName = "Joshua-PC-Nix";
  nvidiaTweaks = true;
  useGrub = false;

  josh.nixServe.enable = true;
  josh.pull-from-work.enable = true;

  # Lanzaboote replaces systemd-boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote.enable = true;
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  josh.operator-mono.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  josh.username = "joshua";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "dialout"
      "docker"
      "wireshark"
    ];
    homeMode = "750"; # Gives plex service read access
    description = "Joshua Baker";
    packages = with pkgs; [
      arduino
      makemkv
      obs-studio
      prismlauncher
      protonvpn-gui
      qbittorrent
      qbittorrent-nox
    ];
  };

  # Disable GDM auto-suspend which broadcasts terminal messages and messes with services while I'm using the machine remotely!!!
  services.displayManager.gdm.autoSuspend = false;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpeg
    gamescope
    retroarch
  ];

  # Necessary for makemkv to find optical drives
  boot.kernelModules = [ "sg" ];

  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/torrents" = ntfs "/dev/disk/by-uuid/FE421851421810CF";
  fileSystems."/windows" = ntfs "/dev/disk/by-uuid/4CC4F3F8C4F3E25E";
  fileSystems."/games" = ntfs "/dev/disk/by-uuid/70125600261870C2";
  fileSystems."/why-not-more" = ntfs "/dev/disk/by-uuid/CCC6C319C6C30326";

  bindMounts = [
    # Wine requires symlinks, but NTFS doesn't do symlinks.
    {
      src = "/home/joshua/steam_compatdata";
      at = "/games/SteamLibrary/steamapps/compatdata";
    }
  ];

  networking.hosts."192.168.1.251" = [ "TheNether" ];
  networking.hosts."192.168.1.107" = [ "e3.custom.local" "docker.enseo.com" ];

  nmconnections = [
    "5207"
    "Joshua"
  ];

  # Causes IPv6 address to change periodically when enabled, which is bad because I have to configure
  # specific firewall rules at the router.
  networking.tempAddresses = "disabled";

  virtualisation.virtualbox.host.enable = true;

  services.httpd = {
    enable = true;
    virtualHosts.http = {
      documentRoot = "/var/www/html";
      listen = [
        {
          ip = "[::]";
          port = 80;
        }
      ];
    };
    # virtualHosts.https = {
    #   documentRoot = "/var/www/html";
    #   listen = [ {
    #     ip = "[::]";
    #     port = 443;
    #     ssl = true;
    #   } ];
    #   sslServerCert = "/etc/ssl/certs/apache-selfsigned.crt";
    #   sslServerKey = "/etc/ssl/private/apache-selfsigned.key";
    # };
    extraConfig = ''
      Header Set Access-Control-Allow-Origin *
      Header Set Access-Control-Allow-Headers *
      Header Set Access-Control-Allow-Methods *
    '';
  };

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
  age.secrets.ddns-updater-config.file = ../secrets/ddns-updater-config-Joshua-PC.age;
  age.secrets.qbittorrent-env.file = ../secrets/qbittorrent-env.age;

  services.ddns-updater.enable = true;
  services.ddns-updater.environment = {
    CONFIG_FILEPATH = "%d/config"; # %d goes to $CREDENTIALS_DIRECTORY
  };
  systemd.services.ddns-updater.serviceConfig = {
    LoadCredential = "config:${config.age.secrets.ddns-updater-config.path}";
  };

  qbittorrent-container.enable = true;
  qbittorrent-container.autostart = true;
  qbittorrent-container.envFile = config.age.secrets.qbittorrent-env.path;

  # 15822 is the external port I use when port forwarding from a NAT router,
  # but there's no NAT when using IPv6, so it's helpful to also listen on this port.
  services.openssh.ports = [
    22
    15822
  ];
  services.openssh.settings.PasswordAuthentication = false;

  services.plex.enable = true;
  # Gives plex read access to /home/joshua/Videos
  systemd.services.plex.serviceConfig.ProtectHome = lib.mkForce false;
  users.users.plex.extraGroups = [ "users" ];

  services.jellyfin.enable = true;

  systemd.tmpfiles.rules = [
    # First delete the file if it's already there
    "r /run/gdm/.config/monitors.xml - - - - -"
    # Copy the file, but you can't change its ownership or permissions
    "C /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
    # Now adjust the ownership
    "Z /run/gdm/.config - gdm gdm - -"
  ];

  # Null sinks are virtual audio devices that simply drop any data sent to them.
  # However, all sinks have monitors, so monitoring a null sink can allow for
  # custom audio routing.
  services.pipewire.extraConfig.pipewire."91-null-sinks" =
    let
      nullSink = name: desc: {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = name;
          "node.description" = desc;
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      };
    in
    {
      "context.objects" = [
        (nullSink "OBS-Capture" "OBS Capture")
        (nullSink "My-Ears" "My Ears")
        (nullSink "Everywhere" "Everywhere")
      ];
    };

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
