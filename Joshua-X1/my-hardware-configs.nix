{ pkgs, config, lib, ... }:
{
  networking.hostName = "Joshua-X1";
  nvidiaTweaks = false;
  useGrub = true;
  josh.operator-mono.enable = true;
  josh.rook-row.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  myUserName = "joshua";
  users.users."${config.myUserName}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "wwwrun" "wireshark" "avahi"];
    description = "Joshua Baker";
  };

  services.avahi.enable = true;
}
