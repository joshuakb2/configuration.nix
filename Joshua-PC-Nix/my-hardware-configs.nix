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
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "wireshark"];
    description = "Joshua Baker";
    packages = with pkgs; [
      arduino
      makemkv
      obs-studio
      qbittorrent
    ];
  };

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
      <Directory /var/www/html>
        Options FollowSymlinks Indexes
        AllowOverride All
      </Directory>

      Header Set Access-Control-Allow-Origin *
      Header Set Access-Control-Allow-Headers *
      Header Set Access-Control-Allow-Methods *
    '';
  };

  services.plex.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];
}
