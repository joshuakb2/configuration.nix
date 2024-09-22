{ pkgs, config, lib, ... }:
{
  networking.hostName = "JBaker-LT";
  nvidiaTweaks = false;
  useGrub = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  myUserName = "jbaker";
  users.users."${config.myUserName}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout"];
    description = "Josh Baker";
  };

  boot.supportedFilesystems = ["ntfs"];
}
