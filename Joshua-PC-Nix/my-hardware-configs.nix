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

  boot.supportedFilesystems = ["ntfs"];

  fileSystems."/torrents" = ntfs "/dev/disk/by-uuid/FE421851421810CF";
  fileSystems."/windows" = ntfs "/dev/disk/by-uuid/AE6A5CC36A5C8A4B";
  fileSystems."/games" = ntfs "/dev/disk/by-uuid/70125600261870C2";

  services.httpd.enable = true;
  services.httpd.virtualHosts.localhost = {
    documentRoot = "/var/www/html";
    listen = [{ port = 80; }];
    extraConfig = ''
      <Directory /var/www/html>
        Options FollowSymlinks Indexes
        AllowOverride All
      </Directory>
    '';
  };

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];
}
