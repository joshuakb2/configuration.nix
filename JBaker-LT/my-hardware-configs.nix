{ pkgs, config, lib, ... }:
{
  networking.hostName = "JBaker-LT";
  nvidiaTweaks = true;
  useGrub = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  myUserName = "jbaker";
  users.users."${config.myUserName}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker"];
    description = "Josh Baker";
  };

  virtualisation.docker.enable = true;

  boot.supportedFilesystems = ["ntfs"];

  services.logind.lidSwitch = "ignore";
  services.upower = {
    enable = true;
    ignoreLid = true;
  };

  environment.binbash = pkgs.bash;

  # DHCP for 10.250.11.0/24 network
  services.kea.dhcp4 =
    let
      option = name: data: { inherit name data; };
    in
    {
      enable = true;
      settings = {
        valid-lifetime = 21600;
        interfaces-config = {
          interfaces = ["enp0s31f6" "enp58s0u1"];
        };
        subnet4 = [
          {
            id = 1;
            pools = [{ pool = "10.250.11.10 - 10.250.11.254"; }];
            subnet = "10.250.11.0/24";
            option-data = [
              (option "domain-name" "stbs.local")
              (option "domain-name-servers" "8.8.8.8")
              (option "routers" "10.250.11.1")
            ];
          }
          {
            id = 2;
            pools = [{ pool = "172.18.0.2 - 172.18.0.32"; }];
            subnet = "172.18.0.0/24";
            option-data = [
              (option "domain-name" "hotel.local")
              (option "domain-name-servers" "8.8.8.8")
              (option "routers" "172.18.0.1")
            ];
          }
        ];
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/kea-leases4.csv";
        };
      };
    };
}
