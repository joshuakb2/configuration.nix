{ pkgs, config, lib, ... }:
{
  networking.hostName = "Joshua-PC-Nix";
  nvidiaTweaks = true;
  useGrub = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  myUserName = "joshua";
  users.users."${config.myUserName}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout"];
    description = "Joshua Baker";
  };

  boot.supportedFilesystems = ["ntfs"];
  fileSystems."/torrents" = {
    device = "/dev/disk/by-uuid/FE421851421810CF";
    fsType = "ntfs";
    options = [
      "defaults"
      "umask=000"
      "dmask=000"
      "fmask=000"
      "windows_names"
    ];
  };
}
